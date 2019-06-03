# frozen_string_literal: true

module Worker
  class GenerateInvoiceJob < ::ApplicationJob
    queue_as 'invoice'

    def perform(account_id:, start_date:, end_date:, invoice_type_id:, is_vendor:)
      account = find_account(account_id)
      return if account.nil?

      inv = Billing::Invoice.new contractor_id: account.contractor_id,
                                 account_id: account.id,
                                 start_date: start_date,
                                 vendor_invoice: is_vendor,
                                 end_date: end_date,
                                 type_id: invoice_type_id
      account.transaction do
        InvoiceGenerator.new(inv).save!
      end
    end

    def find_account(account_id)
      Account.find(account_id)
    rescue ActiveRecord::RecordNotFound => _
      nil
    end
  end
end
