# frozen_string_literal: true

module Partitionable
  extend ActiveSupport::Concern

  included do
    class_attribute :pg_partition_name, instance_accessor: false
    class_attribute :pg_partition_interval_type, instance_accessor: false, default: PgPartition::INTERVAL_MONTH
    class_attribute :pg_partition_depth_future, instance_accessor: false, default: 1
    class_attribute :pg_partition_depth_past, instance_accessor: false, default: 1
  end

  class_methods do
    def pg_partition_class
      pg_partition_name.constantize
    end

    def add_partition_for(time)
      pg_partition_class.add_partition(table_name, pg_partition_interval_type, time.to_time.utc)
    end

    def add_partitions
      timestamps = pg_partition_class.partition_intervals(
        pg_partition_interval_type,
        start_point: Time.now.utc,
        future_depth: pg_partition_depth_future,
        past_depth: pg_partition_depth_past
      )
      timestamps.each(&method(:add_partition_for))
    end

    def partitions
      pg_partition_class.partitions(table_name)
    end
  end
end
