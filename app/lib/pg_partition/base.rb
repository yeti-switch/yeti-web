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
      sql_caller
      remove_partition
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
      existed_partition = partitions(table_name).detect do |r|
        r[:date_from].to_date == from.to_date && r[:date_to].to_date == to.to_date
      end
      return if existed_partition.present?

      execute(
        "CREATE TABLE #{table_name}_#{prefix}
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

    def partitions(table_names, id: nil)
      bindings = [Array.wrap(table_names), id].reject(&:nil?)
      query = <<-SQL
        SELECT
            MD5(nmsp_child.nspname||'.'||child.relname) AS id,
            nmsp_child.nspname||'.'||child.relname AS name,
            nmsp_parent.nspname||'.'||parent.relname AS parent_table,
            pg_get_expr(child.relpartbound, child.oid, true) AS partition_range,
            NULLIF(
              SPLIT_PART(pg_get_expr(child.relpartbound, child.oid, true), '''', 2),
              ''
            )::timestamp with time zone AS date_from,
            NULLIF(
              SPLIT_PART(pg_get_expr(child.relpartbound, child.oid, true), '''', 4),
              ''
            )::timestamp with time zone AS date_to
        FROM pg_inherits
        JOIN pg_class parent ON pg_inherits.inhparent = parent.oid
        JOIN pg_class child ON pg_inherits.inhrelid  = child.oid
        JOIN pg_namespace nmsp_parent ON nmsp_parent.oid = parent.relnamespace
        JOIN pg_namespace nmsp_child ON nmsp_child.oid = child.relnamespace
        WHERE
          nmsp_parent.nspname||'.'||parent.relname IN (?)
          #{"AND MD5(nmsp_child.nspname||'.'||child.relname) = ?" unless id.nil?}
        ORDER BY 2, 1
      SQL
      select_all_serialized(query, *bindings)
    end

    def remove_partition(partition_name)
      execute <<-SQL
        DROP TABLE #{partition_name};
      SQL
    end

    def sql_caller
      return @sql_caller if defined?(@sql_caller)
      raise NotImplementedError, 'define sql_caller via #sql_caller_name class method' if _sql_caller_name.nil?

      @sql_caller = _sql_caller_name.constantize
    end
  end
end
