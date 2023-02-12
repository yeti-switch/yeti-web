# frozen_string_literal: true

module Jobs
  class DialpeerRatesApply < ::BaseJob
    self.cron_line = '* * * * *'
    BATCH_SIZE = 1_000
    # We limit single cron job to apply only first 50k records
    # because it takes to much time to process more in one run.
    # Next 50k will be applied in a minute (job runs every minute).
    RECORDS_LIMIT = 50_000

    def execute
      applied = 0

      DialpeerNextRate.ready_for_apply.find_in_batches(batch_size: BATCH_SIZE) do |rates|
        ApplicationRecord.transaction do
          rates.each(&:apply!)
        end
        applied += rates.size
        break if applied >= RECORDS_LIMIT
      end
      return if applied >= RECORDS_LIMIT

      Routing::DestinationNextRate.ready_for_apply.find_in_batches(batch_size: BATCH_SIZE) do |rates|
        ApplicationRecord.transaction do
          rates.each(&:apply!)
        end
        applied += rates.size
        break if applied >= RECORDS_LIMIT
      end
    end
  end
end
