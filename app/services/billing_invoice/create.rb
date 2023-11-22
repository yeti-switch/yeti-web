# frozen_string_literal: true

module BillingInvoice
  class Create < ApplicationService
    parameter :account, required: true
    parameter :type_id, required: true
    parameter :start_time, required: true
    parameter :end_time, required: true

    delegate :contractor, to: :account

    def call
      AdvisoryLock::Cdr.with_lock(:invoice, id: account.id) do
        account.reload
        validate!

        invoice = Billing::Invoice.create!(
            contractor: contractor,
            account: account,
            type_id: type_id,
            start_date: start_time,
            end_date: end_time
          )
        invoice.update! reference: build_reference(invoice)
        Worker::FillInvoiceJob.perform_later(invoice.id)
        invoice
      end
    rescue ActiveRecord::RecordInvalid => e
      message = e.record ? e.record.errors.full_messages.join(', ') : e.message
      raise Error, message
    end

    private

    def build_reference(invoice)
      template = account.public_send(:invoice_ref_template)
      InvoiceRefTemplate.call(invoice, template)
    end

    def validate!
      start_date = start_time.in_time_zone(Time.zone)
      end_date = end_time.in_time_zone(Time.zone)
      CaptureError.with_exception_context(extra: { start_date: start_date, end_date: end_date, params: _params }) do
        raise Error, 'type_id must be present' if type_id.blank?
        raise Error, 'start_time must be present' if start_time.blank?
        raise Error, 'end_time must be present' if end_time.blank?
        raise Error, 'start_time must be less then end_time' if start_time.to_i >= end_time.to_i
        raise Error, "end_time can't be in future" if end_time.to_i > Time.now.to_i

        CaptureError.with_exception_context(extra: { covered_invoice_ids: covered_invoice_ids }) do
          raise Error, 'have invoice inside provided period' if covered_invoice_ids.any?
        end
      end
    end

    define_memoizable :covered_invoice_ids, apply: lambda {
      start_date = start_time.in_time_zone(Time.zone)
      end_date = end_time.in_time_zone(Time.zone)

      covered_invoices = Billing::Invoice
                         .where(account_id: account.id)
                         .cover_period(start_date, end_date)

      covered_invoices.pluck(:id)
    }
  end
end
