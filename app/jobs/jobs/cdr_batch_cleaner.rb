# frozen_string_literal: true

module Jobs
  class CdrBatchCleaner < ::BaseJob
    self.cron_line = '*/30 * * * *'

    def execute
      Billing::CdrBatch.fetch_sp_val('DELETE FROM billing.cdr_batches where id not in (SELECT id from billing.cdr_batches order by id desc limit 50);')
    end
  end
end
