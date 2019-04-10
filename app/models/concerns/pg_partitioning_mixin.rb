# frozen_string_literal: true

# Module mixis in ActiveRecord class
# to add "Postgres Table Partitioning" behaviour
#
#  Partition divides table with datetime-column by months
#
# Usage:
#
# For example we have table `log.my_logs` with column `time` (timestamp)
#
# First create migration identical to `sys.auth_log_tables`.
# In example case it will be `sys.my_logs_tables`
#
# This table must have trigger and trigger function, for example:
#
#      CREATE OR REPLACE FUNCTION log.my_logs_i_tgf() RETURNS trigger AS $trg$
#      BEGIN
#        RAISE EXCEPTION 'log.my_logs_i_tg: time out of range.';
#        RETURN NULL;
#      END; $trg$
#      LANGUAGE plpgsql VOLATILE COST 100;
#
#      CREATE TRIGGER my_logs_i BEFORE INSERT
#        ON log.my_logs
#        FOR EACH ROW
#        EXECUTE PROCEDURE log.my_logs_i_tgf();
#
# Then create model:
#
# class MyLogTables < Yeti::ActiveRecord
#  self.table_name = 'sys.auth_log_tables'
#
#  include PgPartitioningMixin
#
#  self.partitioned_model = MyLog    # with `self.table_name = 'log.my_logs'`
#  self.partition_schema = 'log'
#  self.partition_key = :time        # column name
#  self.trigger_function_name = 'log.my_logs_i_tgf'
#  self.trigger_name = 'log.my_logs_i_tg'
#
#  has_paper_trail class_name: 'AuditLogItem'
#
#  scope :active, -> { where active: true }
#
#  def display_name
#    "#{self.name}"
#  end
#
#
# Next step is create Job for automation
# refer to `jobs/jobs/cdr_partitioning.rb`
#
#
module PgPartitioningMixin
  extend ActiveSupport::Concern

  included do
    mattr_accessor :partitioned_model, :partition_schema,
                   :partition_key, :partition_range,
                   :trigger_function_name, :trigger_name

    self.partition_range = :month # :month | :day
  end

  class_methods do
    def add_partition
      today = Date.today
      transaction do
        time_slices.each do |from, to|
          create_table(from, to)
        end
      end
    end

    def reload_insertion_trigger
      cases = active.order(:date_start).map do |t|
        "(NEW.#{partition_key} >= '#{t.date_start} 00:00:00+00' AND NEW.#{partition_key} < '#{t.date_stop} 00:00:00+00') THEN
            INSERT INTO #{t.name} VALUES (NEW.*);"
      end

      if cases.any?
        connection.execute %{
          CREATE OR REPLACE FUNCTION #{trigger_function_name}() RETURNS trigger AS $trg$
          BEGIN
            IF #{cases.join("\n          ELSIF ")}
            ELSE
              RAISE EXCEPTION '#{trigger_name}: #{partition_key} out of range.';
            END IF;
            RETURN NULL;
          END; $trg$
          LANGUAGE plpgsql VOLATILE COST 100;
        }
      end
    end

    def partitions
      order(:date_start).map(&:name)
    end

    def partitioned_table
      partitioned_model.table_name
    end

    def partitioned_table_without_schema
      partitioned_table.split('.').last
    end

    def partition_prefix
      partitioned_table_without_schema
    end

    # output:
    #
    # [
    #   [2018-05-01, 2018-05-06],
    #   [2018-06-01, 2018-07-06],
    #   [2018-07-01, 2018-08-06],
    #   [2018-08-01, 2018-09-06],
    #   [2018-09-01, 2018-10-06]
    # ]
    # # OR
    # [
    #   [2018-06-24, 2018-06-25],
    #   [2018-06-25, 2018-06-26],
    #   [2018-06-26, 2018-06-27],
    #   [2018-06-27, 2018-06-28],
    #   [2018-06-28, 2018-06-29]
    # ]
    #
    def time_slices(max_slices = 5)
      today = Date.today
      starting_point = partition_range == :day ?
        today - 2.day : today.beginning_of_month - 2.month
      (1..max_slices).map do |i|
        [starting_point + (i - 1).send(partition_range),
         starting_point + i.send(partition_range)]
      end
    end

    private

    def create_table(date_from, date_to)
      party = PgPartitioning::Partition.new(date_from: date_from, date_to: date_to, parent: self)
      unless party.exists?
        party.create
        reload_insertion_trigger
      end
    end
  end
end
