# frozen_string_literal: true

module Jobs
  class CdrCompaction < ::BaseJob
    include Memoizable

    self.cron_line = '40 */3 * * *'

    def execute
      partition_class = PartitionModel::Cdr
      model_class = Cdr::Cdr
      table_name = model_class.table_name

      compaction_delay = cdr_compaction_delay
      if compaction_delay.blank?
        logger.info { "#{self.class}: compaction disabled" }
        return
      end

      already_compacted_tables = Cdr::CdrCompactedTable.pluck(:table_name)

      cdr_collection = partition_class
                       .where(parent_table_eq: table_name)
                       .to_a
                       .select { |r| r.date_to <= compaction_delay.days.ago.utc && already_compacted_tables.exclude?(r.name) }
                       .sort_by(&:date_to)

      if cdr_collection.empty?
        logger.info { "#{self.class}: does not enough partitions for #{table_name}" }
        return
      end

      cdr_compaction_candidate = cdr_collection.first
      return unless execute_cmd!(cdr_compaction_candidate.name)

      handle_compaction_candidate!(cdr_compaction_candidate)
    rescue Errno::ENOENT => e
      # usually raised on hook execution
      logger.error { "Partition removing hook failed #{self.class}: #{cdr_compaction_candidate&.name} - #{e.message}" }
      capture_error(e, extra: { partition_class: partition_class, model_class: model_class })
    rescue ActiveRecord::RecordNotDestroyed => e
      logger.error { "#{self.class}: #{cdr_compaction_candidate&.name} - #{e.message}" }
      capture_error(e, extra: { partition_class: partition_class, model_class: model_class })
    rescue StandardError => e
      logger.error { "#{self.class}: #{cdr_compaction_candidate&.name} - <#{e.class}>: #{e.message}\n#{e.backtrace.join("\n")}" }
      capture_error(e, extra: { partition_class: partition_class.name, model_class: model_class.name })
      raise e
    end

    private

    define_memoizable :cdr_compaction_delay, apply: lambda {
      YetiConfig.cdr_compaction_delay
    }

    define_memoizable :cdr_compaction_hook, apply: lambda {
      YetiConfig.cdr_compaction_hook
    }

    define_memoizable :cdr_compaction_queries, apply: lambda {
      YetiConfig.cdr_compaction_queries || []
    }

    def execute_cmd!(candidate_table_name)
      return true if cdr_compaction_hook.blank?

      cmd = "#{cdr_compaction_hook} #{candidate_table_name}"
      collect_prometheus_executions_metric!
      start_time = get_time

      Open3.popen3(cmd) do |_stdin, stdout, stderr, wait_thr|
        logger.info { "Partition remove hook stdout:\n#{stdout.read}" }
        logger.info { "Partition remove hook stderr:\n#{stderr.read}" }
        collect_prometheus_duration_metric!(start_time)

        if wait_thr.value.success?
          logger.info { "Partition remove hook succeed, exit code: #{wait_thr.value.exitstatus}" }
          return true
        else
          logger.error { "Partition remove hook failed: #{wait_thr.value.exitstatus}. Stopping removing procedure" }
          collect_prometheus_errors_metric!
        end

        return false
      end
    end

    def handle_compaction_candidate!(compaction_candidate)
      cdr_compaction_queries.each do |query|
        formatted_query = format(query, table: compaction_candidate.name)
        logger.info { "Executing compaction query: #{formatted_query}" }
        result = Cdr::Base.connection.execute(formatted_query)
        logger.info { "Compaction query result: #{result.cmd_tuples} rows affected" }
      end

      Cdr::CdrCompactedTable.create!(table_name: compaction_candidate.name)
    end

    def collect_prometheus_executions_metric!
      CdrCompactionHookProcessor.collect_executions_metric if PrometheusConfig.enabled?
    end

    def collect_prometheus_errors_metric!
      CdrCompactionHookProcessor.collect_errors_metric if PrometheusConfig.enabled?
    end

    def collect_prometheus_duration_metric!(start_time)
      return unless PrometheusConfig.enabled?

      duration = (get_time - start_time).round(6)
      CdrCompactionHookProcessor.collect_duration_metric(duration)
    end

    def get_time
      ::Process.clock_gettime(::Process::CLOCK_MONOTONIC)
    end
  end
end
