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

        invoice = BillingInvoice::Create.call(
          account: account,
          is_vendor: is_vendor,
          start_time: invoice_params[:start_time],
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
