# frozen_string_literal: true

module Jobs
  class CdrBatchCleaner < ::BaseJob
    self.cron_line = '*/30 * * * *'

    def execute
      Billing::CdrBatch.fetch_sp_val('SELECT * from billing.clean_cdr_batch();')
    end
  end
end
