# frozen_string_literal: true

module PgPartition
  class Base
    include Singleton
    extend Forwardable
    extend SingleForwardable

    class_attribute :_sql_caller_name, instance_writer: false

    single_delegate %i[
      add_partition
      add_partition_for_range
      partition_options
      partition_intervals
      partitions
    ] => :instance

    instance_delegate %i[
      execute
      select_all_serialized
    ] => :sql_caller

    class << self
      def sql_caller_name(class_name)
        self._sql_caller_name = class_name.to_s
      end
    end

    def add_partition(table_name, interval_type, time)
      options = partition_options(interval_type, time)
      add_partition_for_range(table_name, options)
    end

    def add_partition_for_range(table_name, prefix:, from:, to:)
      execute(
        "CREATE TABLE IF NOT EXISTS #{table_name}_#{prefix}
        PARTITION OF #{table_name}
        FOR VALUES FROM (?) TO (?)",
        from, to
      )
    end

    def partition_options(interval_type, time)
      case interval_type
      when PgPartition::INTERVAL_MONTH
        from = time.to_date.beginning_of_month
        to = from + 1.month
        prefix = from.to_date.strftime('%Y_%m')
        { from: from, to: to, prefix: prefix }
      when PgPartition::INTERVAL_DAY
        from = time.to_date
        to = from + 1.day
        prefix = from.to_date.strftime('%Y_%m_%d')
        { from: from, to: to, prefix: prefix }
      when Proc
        interval_type.call(time)
      else
        raise ArgumentError, "invalid interval type #{interval_type}"
      end
    end

    def partition_intervals(interval_type, start_point: Time.now.utc, future_depth: 0, past_depth: 0)
      steps = []
      start_point_opts = partition_options(interval_type, start_point)
      steps << start_point_opts
      past_depth.times do
        time = steps.first[:from] - 1.second
        steps.unshift partition_options(interval_type, time)
      end
      future_depth.times do
        time = steps.last[:to]
        steps.push partition_options(interval_type, time)
      end
      steps.map { |opts| opts[:from] }
    end

    def partitions(table_names)
      table_names = Array.wrap(table_names).map { |t_name| t_name.split('.') }
      select_all_serialized(
        "SELECT
          nmsp_child.nspname||'.'||child.relname AS partition
          nmsp_parent.nspname||'.'||parent.relname AS parent
        FROM pg_inherits
        JOIN pg_class parent            ON pg_inherits.inhparent = parent.oid
        JOIN pg_class child             ON pg_inherits.inhrelid  = child.oid
        JOIN pg_namespace nmsp_parent   ON nmsp_parent.oid       = parent.relnamespace
        JOIN pg_namespace nmsp_child    ON nmsp_child.oid        = child.relnamespace
        WHERE
          #{table_names.map { '(nmsp_parent.nspname = ? AND parent.relname = ?)' }.join(" OR\n")}
        ORDER BY 2, 1",
        *table_names.flatten
      )
    end

    private

    def sql_caller
      return @sql_caller if defined?(@sql_caller)
      raise NotImplementedError, 'define sql_caller via #sql_caller_name class method' if _sql_caller_name.nil?

      @sql_caller = _sql_caller_name.constantize
    end
  end
end
