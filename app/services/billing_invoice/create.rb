# frozen_string_literal: true

module BillingInvoice
  class Create < ApplicationService
    parameter :account, required: true
    parameter :type_id, required: true
    parameter :start_time, required: true
    parameter :end_time, required: true
    parameter :is_vendor, required: true

    delegate :contractor, to: :account

    def call
      AdvisoryLock::Cdr.with_lock(:invoice, id: account.id) do
        account.reload
        validate!

        invoice = Billing::Invoice.create!(
            contractor: contractor,
            account: account,
            type_id: type_id,
            vendor_invoice: is_vendor,
            start_date: start_time,
            end_date: end_time
          )
        Worker::FillInvoiceJob.perform_later(invoice.id)
        invoice
      end
    rescue ActiveRecord::RecordInvalid => e
      message = e.record ? e.errors.full_messages.join(', ') : e.message
      raise Error, message
    end

    private

    def validate!
      raise Error, 'type_id must be present' if type_id.blank?
      raise Error, 'start_time must be present' if start_time.blank?
      raise Error, 'end_time must be present' if end_time.blank?
      raise Error, 'start_time must be less then end_time' if start_time.to_i >= end_time.to_i
      raise Error, 'is_vendor must be passed' if is_vendor.nil?
      raise Error, "end_time can't be in future" if end_time.to_i > Time.now.to_i
      raise Error, 'have invoice inside provided period' if have_covered_invoices?
    end

    def have_covered_invoices?
      start_time_server = start_time.in_time_zone(Time.zone)

      Billing::Invoice
        .where(account_id: account.id, vendor_invoice: is_vendor)
        .where('end_date >= ?', start_time_server)
        .any?
    end
  end
end
