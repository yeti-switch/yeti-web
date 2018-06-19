module PgPartitioning

  class Partition
    attr_accessor :parent, :date_from, :date_to

    delegate :partition_key, :connection, to: :parent

    def initialize(date_from:, date_to:, parent:)
      self.date_from = date_from
      self.date_to = date_to
      self.parent = parent
    end


    def name
      date_format = (parent.partition_range == :day) ? '%Y%m%d' : '%Y%m'
      "#{ parent.partition_prefix }_#{ date_from.strftime(date_format) }"
    end

    def table_name
      "#{parent.partition_schema}.#{name}"
    end

    # Only creates partition table
    # Example: `cdr.cdr_201807`
    def create
      connection.execute %Q{
        CREATE TABLE IF NOT EXISTS #{table_name} (
          CONSTRAINT #{name}_#{partition_key}_check CHECK (
            #{partition_key} >= '#{date_from.to_s(:db)} 00:00:00+00'
              AND #{partition_key} < '#{date_to.to_s(:db)} 00:00:00+00'
          )
        ) INHERITS (#{parent.partitioned_table});
      }
      reindex
      write_partition_info
    end

    # Only add information about partition-table to "primary" table
    # For example into `sys.cdr_tables`
    def write_partition_info
      parent.create!(name: table_name,
                     date_start: date_from.to_s(:db),
                     date_stop: date_to.to_s(:db),
                     writable: true,
                     readable: true)
    end

    # Add indexes for partition table, if needed
    # - add primary_key to ID
    # - recreate index on partition-key-column, for example 'time_start'
    def reindex
      add_primary_key unless primary_key?
      column_key_index = column_index(partition_key)

      if column_key_index.present?
        connection.remove_index(table_name, name: column_key_index.name)
      end
      connection.add_index(table_name, partition_key, using: 'btree')
    end

    # Check if partition table exists
    # And corresponding record should be in "partition-info-table"(example: `sys.cdr_tables`)
    # both conditions should be TRUE
    def exists?
      connection.table_exists?(table_name) && parent.exists?(name: table_name)
    end

    private

      def primary_key?
        res = connection.exec_query %Q{
          SELECT constraint_name
          FROM information_schema.table_constraints
          WHERE table_name = '#{name}'
            AND table_schema='#{parent.partition_schema}'
            AND constraint_type = 'PRIMARY KEY'
        }
        res.count
      end

      def column_index(column_name)
        connection.indexes(table_name).detect do |ind|
          ind.columns.include?(column_name.to_s)
        end
      end

      def add_primary_key
        connection.execute %Q{
          ALTER TABLE #{table_name} ADD PRIMARY KEY (id);
        }
      end
  end

end
