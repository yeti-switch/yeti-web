# frozen_string_literal: true

module Jobs
  class Invoice < ::BaseJob
    def execute
      Account.ready_for_customer_invoice.find_each do |account|
        capture_job_extra(id: account.id, type: :customer) do
          BillingInvoice::Generate.call(account: account, is_vendor: false)
        end
      end

      Account.ready_for_vendor_invoice.each do |account|
        capture_job_extra(id: account.id, type: :vendor) do
          BillingInvoice::Generate.call(account: account, is_vendor: true)
        end
      end
    end

    def customers_accounts
      Account.ready_for_customer_invoice
    end

    def vendors_accounts
      Account.ready_for_vendor_invoice
    end
  end
end
