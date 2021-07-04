# frozen_string_literal: true

module Jobs
  class ReportScheduler < ::BaseJob
    self.cron_line = '*/15 * * * *'

    def execute
      customer_traffic_tasks.each do |t|
        capture_job_extra(id: t.id, class: t.class.name) do
          ApplicationRecord.transaction do
            timedata = t.reschedule(time_now)
            Report::CustomerTraffic.create!(
              date_start: timedata.date_from,
              date_end: timedata.date_to,
              customer_id: t.customer_id,
              send_to: t.send_to
            )
            t.last_run_at = time_now
            t.next_run_at = timedata.next_run_at
            t.save!
          end
        end
      end

      custom_cdr_tasks.each do |t|
        capture_job_extra(id: t.id, class: t.class.name) do
          ApplicationRecord.transaction do
            timedata = t.reschedule(time_now)
            Report::CustomCdr.create!(
              date_start: timedata.date_from,
              date_end: timedata.date_to,
              customer_id: t.customer_id,
              filter: t.filter,
              group_by_fields: t.group_by, # TODO: rewrite reports to use Arrays for group_by instead varchar
              send_to: t.send_to
            )
            t.last_run_at = time_now
            t.next_run_at = timedata.next_run_at
            t.save!
          end
        end
      end

      interval_cdr_tasks.each do |t|
        capture_job_extra(id: t.id, class: t.class.name) do
          ApplicationRecord.transaction do
            timedata = t.reschedule(time_now)
            Report::IntervalCdr.create!(
              date_start: timedata.date_from,
              date_end: timedata.date_to,
              filter: t.filter,
              group_by_fields: t.group_by, # TODO: rewrite reports to use Arrays for group_by instead varchar
              aggregator_id: t.aggregator_id,
              aggregate_by: t.aggregate_by,
              interval_length: t.interval_length,
              send_to: t.send_to
            )
            t.last_run_at = time_now
            t.next_run_at = timedata.next_run_at
            t.save!
          end
        end
      end

      vendor_traffic_tasks.each do |t|
        capture_job_extra(id: t.id, class: t.class.name) do
          ApplicationRecord.transaction do
            timedata = t.reschedule(time_now)
            Report::VendorTraffic.create!(
              date_start: timedata.date_from,
              date_end: timedata.date_to,
              vendor_id: t.vendor_id,
              send_to: t.send_to
            )
            t.last_run_at = time_now
            t.next_run_at = timedata.next_run_at
            t.save!
          end
        end
      end
    end

    def customer_traffic_tasks
      Report::CustomerTrafficScheduler.where('next_run_at<?', time_now)
    end

    def vendor_traffic_tasks
      Report::VendorTrafficScheduler.where('next_run_at<?', time_now)
    end

    def custom_cdr_tasks
      Report::CustomCdrScheduler.where('next_run_at<?', time_now)
    end

    def interval_cdr_tasks
      Report::IntervalCdrScheduler.where('next_run_at<?', time_now)
    end

    def time_now
      @time_now ||= Time.now
    end
  end
end
