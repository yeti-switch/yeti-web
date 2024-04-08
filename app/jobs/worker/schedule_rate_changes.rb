# frozen_string_literal: true

module Worker
  class ScheduleRateChanges < ApplicationJob
    queue_as 'batch_actions'

    BATCH_SIZE = 1000

    attr_reader :ids_sql

    def perform(ids_sql, rate_attrs)
      @ids_sql = ids_sql

      ApplicationRecord.transaction do
        destination_ids.each_slice(BATCH_SIZE) do |ids|
          Destination::ScheduleRateChanges.call(ids:, **rate_attrs)
        end
      end
    end

    private

    def destination_ids
      ApplicationRecord.connection.select_values(ids_sql)
    end
  end
end
