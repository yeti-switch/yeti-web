# frozen_string_literal: true

module Jobs
  class DialpeerRatesApply < ::BaseJob
    self.cron_line = '* * * * *'

    def execute
      ApplicationRecord.transaction do
        DialpeerNextRate.ready_for_apply.find_each do |rate|
          capture_job_extra(id: rate.id, class: rate.class.name) do
            rate.dialpeer.update!(
              current_rate_id: rate.id,
              initial_interval: rate.initial_interval,
              next_interval: rate.next_interval,
              initial_rate: rate.initial_rate,
              next_rate: rate.next_rate,
              connect_fee: rate.connect_fee
            )
            rate.update!(applied: true)
          end
        end

        Routing::DestinationNextRate.ready_for_apply.find_each do |rate|
          CaptureError.with_exception_context(extra: { id: rate.id, class: rate.class.name }) do
            rate.destination.update!(
              # current_rate_id: rate.id,
              initial_interval: rate.initial_interval,
              next_interval: rate.next_interval,
              initial_rate: rate.initial_rate,
              next_rate: rate.next_rate,
              connect_fee: rate.connect_fee
            )
            rate.update!(applied: true)
          end
        end
      end
    end
  end
end
