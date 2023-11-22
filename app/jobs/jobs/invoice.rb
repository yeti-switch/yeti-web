# frozen_string_literal: true

module Jobs
  class Invoice < ::BaseJob
    self.cron_line = '30 5 * * *'

    def execute
      Account.ready_for_invoice.find_each do |account|
        capture_job_extra(id: account.id) do
          BillingInvoice::Generate.call(account: account)
        end
      end
    end
  end
end
