# frozen_string_literal: true

require 'prometheus/partition_remove_hook_processor'

module Jobs
  class PartitionRemoving < ::BaseJob
    self.cron_line = '20 * * * *'
    self.timeout = 7200

    def execute
      remove_partition! PartitionModel::Cdr, Cdr::Cdr
      remove_partition! PartitionModel::Cdr, Cdr::AuthLog
      remove_partition! PartitionModel::Cdr, RtpStatistics::TxStream
      remove_partition! PartitionModel::Cdr, RtpStatistics::RxStream
      remove_partition! PartitionModel::Log, Log::ApiLog
    end

    private

    def partition_remove_delay
      YetiConfig.partition_remove_delay
    end

    def execute_cmd(cmd)
      Open3.popen3(cmd) do |_stdin, _stdout, _stderr, wait_thr|
        o = _stdout.read
        e = _stderr.read
        return wait_thr.value, o, e
      end
    end

    def remove_partition!(partition_class, model_class)
      table_name = model_class.table_name
      remove_delay = partition_remove_delay[table_name]
      if remove_delay.blank?
        logger.info { "#{self.class}: blank remove delay for #{table_name}" }
        return
      end

      # has format /\A\d+ days\z/
      remove_delay = remove_delay.split(' ').first.to_i
      cdr_collection = partition_class
                       .where(parent_table_eq: table_name)
                       .to_a
                       .select { |r| r.date_to <= remove_delay.days.ago.utc }
                       .sort_by(&:date_to)

      if cdr_collection.empty?
        logger.info { "#{self.class}: does not enough partitions for #{table_name}" }
        return
      end

      cdr_remove_candidate = cdr_collection.first

      if YetiConfig.partition_remove_hook.present?
        start_time = get_time
        cmd = "#{YetiConfig.partition_remove_hook} #{cdr_remove_candidate.class} #{cdr_remove_candidate.parent_table} #{cdr_remove_candidate.name}"

        logger.info { "Running partition removing hook: #{cmd}" }
        collect_prometheus_executions_metric!

        return_value, sout, serr = execute_cmd(cmd)

        logger.info { "Partition remove hook stdout:\n#{sout}" }
        logger.info { "Partition remove hook stderr:\n#{serr}" }
        collect_prometheus_duration_metric!(start_time)

        if return_value.success?
          logger.info { "Partition remove hook succeed, exit code: #{return_value.exitstatus}" }
        else
          logger.info { "Partition remove hook failed: #{return_value.exitstatus}. Stopping removing procedure" }
          collect_prometheus_errors_metric!
          return
        end
      end

      cdr_remove_candidate.destroy!
    rescue Errno::ENOENT => e
      # usually raised on hook execution
      logger.error { "Partition removing hook failed #{self.class}: {#{table_name}} #{cdr_remove_candidate&.name} - #{e.message}" }
      capture_error(e, extra: { partition_class: partition_class, model_class: model_class })
    rescue ActiveRecord::RecordNotDestroyed => e
      logger.error { "#{self.class}: {#{table_name}} #{cdr_remove_candidate&.name} - #{e.message}" }
      capture_error(e, extra: { partition_class: partition_class, model_class: model_class })
    rescue StandardError => e
      logger.error { "#{self.class}: {#{table_name}} <#{e.class}>: #{e.message}\n#{e.backtrace.join("\n")}" }
      capture_error(e, extra: { partition_class: partition_class.name, model_class: model_class.name })
      raise e
    end

    def collect_prometheus_executions_metric!
      PartitionRemoveHookProcessor.collect_executions_metric if PrometheusConfig.enabled?
    end

    def collect_prometheus_errors_metric!
      PartitionRemoveHookProcessor.collect_errors_metric if PrometheusConfig.enabled?
    end

    def collect_prometheus_duration_metric!(start_time)
      return unless PrometheusConfig.enabled?

      duration = duration = (get_time - start_time).round(6)
      PartitionRemoveHookProcessor.collect_duration_metric(duration)
    end

    def get_time
      ::Process.clock_gettime(::Process::CLOCK_MONOTONIC)
    end
  end
end
