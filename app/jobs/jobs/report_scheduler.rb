# frozen_string_literal: true

module Jobs
  class ReportScheduler < ::BaseJob
    self.cron_line = '*/15 * * * *'

    def execute
      customer_traffic_tasks.each do |task|
        process_task(task) do |time_data|
          CreateReport::CustomerTraffic.call(
            date_start: time_data.date_from,
            date_end: time_data.date_to,
            customer: task.customer,
            send_to: task.send_to
          )
        end
      end

      custom_cdr_tasks.each do |task|
        process_task(task) do |time_data|
          CreateReport::CustomCdr.call(
            date_start: time_data.date_from,
            date_end: time_data.date_to,
            customer: task.customer,
            filter: task.filter,
            group_by: task.group_by,
            send_to: task.send_to
          )
        end
      end

      interval_cdr_tasks.each do |task|
        process_task(task) do |time_data|
          CreateReport::IntervalCdr.call(
            date_start: time_data.date_from,
            date_end: time_data.date_to,
            filter: task.filter,
            group_by: task.group_by,
            aggregation_function: task.aggregation_function,
            aggregate_by: task.aggregate_by,
            interval_length: task.interval_length,
            send_to: task.send_to
          )
        end
      end

      vendor_traffic_tasks.each do |task|
        process_task(task) do |time_data|
          CreateReport::VendorTraffic.call(
            date_start: time_data.date_from,
            date_end: time_data.date_to,
            vendor_id: task.vendor,
            send_to: task.send_to
          )
        end
      end
    end

    def process_task(task)
      capture_job_extra(id: task.id, class: task.class.name) do
        Cdr::Base.transaction do
          time_data = task.reschedule(time_now)
          yield(time_data)
          task.update!(last_run_at: time_now, next_run_at: time_data.next_run_at)
        end
      end
    end

    def customer_traffic_tasks
      Report::CustomerTrafficScheduler.where('next_run_at<?', time_now).preload(:customer)
    end

    def vendor_traffic_tasks
      Report::VendorTrafficScheduler.where('next_run_at<?', time_now).preload(:vendor)
    end

    def custom_cdr_tasks
      Report::CustomCdrScheduler.where('next_run_at<?', time_now).preload(:customer)
    end

    def interval_cdr_tasks
      Report::IntervalCdrScheduler.where('next_run_at<?', time_now).preload(:aggregation_function)
    end

    def time_now
      @time_now ||= Time.now
    end
  end
end
