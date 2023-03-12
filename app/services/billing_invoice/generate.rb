# frozen_string_literal: true

module BillingInvoice
  class Generate < ApplicationService
    parameter :account, required: true
    parameter :is_vendor, required: true

    # @return [Billing::Invoice]
    def call
      AdvisoryLock::Cdr.with_lock(:invoice, id: account.id) do
        invoice_params = BillingInvoice::CalculatePeriod::Next.call(
          account: account,
          is_vendor: is_vendor,
          period_end: account_invoice_at
        )
        start_time = choose_start_time! invoice_params[:start_time]

        invoice = BillingInvoice::Create.call(
          account: account,
          is_vendor: is_vendor,
          start_time: start_time,
          end_time: account_invoice_at,
          type_id: account_invoice_type_id
        )

        schedule_next_invoice!(invoice_params)
        invoice
      end
    rescue BillingInvoice::Create::Error => e
      raise Error, e.message
    rescue ActiveRecord::RecordInvalid => e
      message = e.record ? e.errors.full_messages.join(', ') : e.message
      raise Error, message
    end

    private

    # When there is invoice that have end_date newer (bigger) than calculated start_time
    # we move invoice start_date to this end_date,
    # because otherwise creation will be failed.
    # @param calc_start_time [Time] calculated start_date for new invoice based on account.
    # @return [Time] start_date that should be used for new invoice based on currently existing invoices.
    def choose_start_time!(calc_start_time)
      invoice_scope = Billing::Invoice.where(account_id: account.id, vendor_invoice: is_vendor)
      last_invoice_end_date = invoice_scope.pick(Arel.sql('MAX(end_date)'))
      return calc_start_time if last_invoice_end_date.nil?

      if last_invoice_end_date >= account_invoice_at
        raise Error, 'invoice exists with end_date greater than or equal to current end_date'
      end

      [calc_start_time, last_invoice_end_date].max
    end

    def schedule_next_invoice!(invoice_params)
      if is_vendor
        account.update!(
          next_vendor_invoice_at: invoice_params[:next_end_time],
          next_vendor_invoice_type_id: invoice_params[:next_type_id]
        )
      else
        account.update!(
          next_customer_invoice_at: invoice_params[:next_end_time],
          next_customer_invoice_type_id: invoice_params[:next_type_id]
        )
      end
    end

    def account_invoice_at
      is_vendor ? account.next_vendor_invoice_at : account.next_customer_invoice_at
    end

    def account_invoice_type_id
      is_vendor ? account.next_vendor_invoice_type_id : account.next_customer_invoice_type_id
    end
  end
end
