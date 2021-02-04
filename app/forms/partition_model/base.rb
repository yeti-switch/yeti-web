# frozen_string_literal: true

module PartitionModel
  class Base
    FakeColumn = Struct.new(:name)

    include ActiveModel::Model
    include ActiveModel::Attributes
    include WithQueryBuilder

    class_attribute :pg_partition_name, instance_accessor: false
    class_attribute :pg_partition_model_names, instance_accessor: false
    class_attribute :logger, instance_writer: false, default: Rails.logger
    class_attribute :primary_key, instance_accessor: false, default: :id
    single_delegate [:sql_caller] => :pg_partition_class

    class << self
      def query_builder_find(id, params)
        raise ArgumentError, 'id must be present' if id.blank?

        logger.debug { "[#{name}] FIND ONE id=#{id} with params=#{params}" }

        filters = params[:filters]
        filters.assert_valid_keys(:parent_table_eq)

        # filter by parent_table
        parent_table_eq = filters[:parent_table_eq]
        table_names = partitioned_tables.include?(parent_table_eq) ?
                          [parent_table_eq] : partitioned_tables

        row = pg_partition_class.partitions(table_names, id: id).first
        if row.nil?
          raise ActiveRecord::RecordNotFound.new(
            "Couldn't find #{name} with '#{primary_key}'=#{id}",
            name,
            primary_key,
            id
          )
        end

        record = new(row)
        apply_table_size [record]
        apply_records_count [record]
        record
      end

      def query_builder_collection(params)
        logger.debug { "[#{self}] FIND COLLECTION with params=#{params}" }

        filters = params[:filters]
        filters.assert_valid_keys(:parent_table_eq)

        # filter by parent_table
        parent_table_eq = filters[:parent_table_eq]
        table_names = partitioned_tables.include?(parent_table_eq) ?
                          [parent_table_eq] : partitioned_tables

        rows = pg_partition_class.partitions(table_names)
        records = rows.map(&method(:new))
        apply_table_size(records)
        apply_records_count(records)
        records
      end

      def apply_table_size(records)
        names = records.map(&:name)
        result = sql_caller.table_size(names).group_by { |r| r[:name] }
        records.each do |record|
          table_size = result[record.name]&.first || {}
          record.size = table_size[:size]
          record.total_size = table_size[:total_size]
        end
      end

      def apply_records_count(records)
        names = records.map(&:name)
        result = sql_caller.approximate_row_count(names).group_by { |r| r[:name] }
        records.each do |record|
          table_size = result[record.name]&.first || {}
          record.approximate_row_count = table_size[:approximate_row_count]
        end
      end

      def pg_partition_class
        pg_partition_name.constantize
      end

      def partitioned_tables
        pg_partition_model_names.map { |class_name| class_name.constantize.table_name }
      end

      def column_names
        attribute_types.keys
      end

      def columns
        return @columns if defined?(@columns)

        @columns = attribute_types.keys.map do |name|
          FakeColumn.new(name)
        end
      end

      def base_class
        self
      end

      def find_by_name(name)
        find Digest::MD5.hexdigest(name)
      end
    end

    attribute :id
    attribute :name
    attribute :parent_table
    attribute :partition_range
    attribute :date_from, :time
    attribute :date_to, :time
    attribute :size
    attribute :total_size
    attribute :approximate_row_count, :integer

    def to_param
      public_send self.class.primary_key
    end

    def destroy
      self.class.pg_partition_class.remove_partition(name)
      true
    rescue ActiveRecord::StatementInvalid => e
      errors.add(:base, e.message)
      false
    end

    def destroy!
      destroy || raise(
        ActiveRecord::RecordNotDestroyed.new("Couldn't destroy record", record)
      )
    end
  end
end
