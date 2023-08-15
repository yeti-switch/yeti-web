# frozen_string_literal: true

module ClickhouseReport
  # Base class to query Clickhouse database
  # @example usage:
  #   module ClickhouseReport
  #     class SomeTable < Base
  #       filter 'from-time', column: :time_start, operator: :eq, type: :DateTime
  #       filter :'rate-gteq', column: :rate, operator: :gteq, type: :Float64
  #       filter :'account-id', column: :customer_acc_id, operator: :eq, type: :UInt32, format_value: lambda do |value, opts|
  #         account = Account.find_by(customer_id: opts[:context][:customer].id, uuid: value)
  #         raise InvalidParamValue, "invalid value account-id" if account.nil?
  #
  #         account.id
  #       end
  #
  #       # for custom expressions you can use raw filter
  #       raw_filter :'source-length-gteq', sql: 'length(source) >= {source_length_gteq: UInt32}'
  #       raw_filter :vendor, required: true, format_value: ->(value, _) { 0 }, sql: lambda { |value, opts|
  #         raw_value = opts[:params][:vendor]
  #         if ActiveModel::Type::Boolean.new.cast(raw_value)
  #           'vendor_price > {vendor: UInt32}'
  #         else
  #           'vendor_price = {vendor: UInt32}'
  #         end
  #       }
  #
  #       def prepare_sql(filters)
  #         "SELECT * FROM some_table WHERE #{filters.values.join(' AND ')}}"
  #       end
  #     end
  #   end
  #
  #   params = {
  #     'from-time' => '2019-01-01 00:00:00',
  #     'rate-gteq' => '0.1',
  #     'account-id' => '123e4567-e89b-12d3-a456-426655440000',
  #     'source-length-gteq' => '10',
  #     'vendor' => 'true'
  #   }
  #   context = { customer: Customer.find(1) }
  #   begin
  #     # SQL fill be
  #     # SELECT *
  #     # FROM some_table
  #     # WHERE time_start = '2019-01-01 00:00:00'
  #     #   AND rate >= 0.1
  #     #   AND customer_acc_id = 1
  #     #   AND length(source) >= 10
  #     #   AND vendor_price > 0
  #     rows = SomeTable.new(params, context).collection
  #   rescue ClickhouseReport::SomeTable::Error => e
  #     Rails.logger.error { "<#{e.class}>: #{e.message}" }
  #   end
  #
  class Base
    Operation = Data.define(:name, :sql, :array) do
      # @!method call(column, query_param, type) Generates SQL condition for a filter.
      #   @param column [Symbol,String] column name.
      #   @param query_param [Symbol,String] query param name.
      #   @param type [Symbol,String] type of the column.
      #   @return [String] SQL condition.
      delegate :call, to: :sql
    end

    Filter = Data.define(:param, :sql, :required, :query_param, :array, :format_value) do
      # Returns SQL condition and query params for filter.
      # @param value [String] value from params
      # @param options [Hash] options with keys :context and :params
      # @return [Array<String, Hash>] sql and query params
      def call(value, options)
        query_param_name = "param_#{query_param}"
        query_value = format_value.call(value, options)
        query_params = { query_param_name => query_value }

        [sql, query_params]
      end
    end

    class Error < StandardError
    end

    class ParamError < Error
    end

    class MissingRequiredParams < ParamError
    end

    class InvalidParamValue < ParamError
    end

    class InvalidResponseError < Error
    end

    class_attribute :operations, instance_accessor: false, default: {}
    class_attribute :filters, instance_accessor: false, default: {}

    class << self
      # @param name [Symbol,String] operation name
      # @param sql [Proc] proc that will be called to generate sql condition
      # @param array [Boolean] if true, then param value will be converted to array and sql condition will be repeated
      def define_operation(name, sql:, array: false)
        name = name.to_sym
        raise ArgumentError, "operation #{name} already defined" if operations.key?(name)

        operations[name] = Operation.new(name:, sql:, array:)
      end

      # Defines column filter for param.
      # @param param [Symbol,String] nameof the filter passed in params.
      # @param type [Symbol,String] type of the param passed in params.
      # @param operation [Symbol] operation to use in sql condition,
      #   see available operations at ClickhouseReport::Base::OPERATORS.
      # @param column [Symbol,String] name of the column in Clickhouse table.
      #  can be omitted if it is the same as param underscored.
      # @param required [Boolean] raises ClickhouseReport::Base::MissingRequiredParams if true and param is missing,
      #  default false.
      # @param format_value [Proc] proc that will be called to format value before binding to sql,
      #  default returns value as is.
      def filter(param, type:, operation:, column: nil, required: false, format_value: nil)
        query_param = param.to_s.underscore
        column ||= param.to_s.underscore
        op = operations.fetch(operation.to_sym) { raise ArgumentError, "unknown operation #{operation}" }
        sql = op.call(column, query_param, type)
        raw_filter(param, sql:, required:, format_value:, query_param:, array: op.array)
      end

      # Defines raw filter for param via SQL condition.
      # @param param [Symbol,String] nameof the filter passed in params.
      # @param sql [String] sql condition, that uses query_param.
      # @param query_param [Symbol] name of the param in sql that will be used for binding
      #  can be omitted if it is the same as param underscored.
      # @param required [Boolean] raises ClickhouseReport::Base::MissingRequiredParams if true and param is missing,
      #   default false.
      # @param format_value [Proc] proc that will be called to format value before binding to sql,
      #   default returns value as is.
      # @param array [Boolean] if true, then param value will be converted to array and sql condition will be repeated
      def raw_filter(param, sql:, query_param: nil, required: false, format_value: nil, array: false)
        param = param.to_sym
        raise ArgumentError, "filter with param #{param} already defined" if filters.key?(param)

        query_param ||= param.to_s.underscore
        format_value ||= ->(value, _opts) { value }
        filters[param] = Filter.new(param:, sql:, query_param:, required:, format_value:, array:)
      end

      def required_params
        filters.values.select(&:required).map(&:param)
      end

      private

      def inherited(subclass)
        subclass.operations = operations.dup
        subclass.filters = filters.dup
      end
    end

    define_operation :eq, sql: lambda { |column, query_param, type|
      "#{column} = {#{query_param}: #{type}}"
    }
    define_operation :gteq, sql: lambda { |column, query_param, type|
      "#{column} >= {#{query_param}: #{type}}"
    }
    define_operation :lteq, sql: lambda { |column, query_param, type|
      "#{column} <= {#{query_param}: #{type}}"
    }
    define_operation :gt, sql: lambda { |column, query_param, type|
      "#{column} > {#{query_param}: #{type}}"
    }
    define_operation :lt, sql: lambda { |column, query_param, type|
      "#{column} < {#{query_param}: #{type}}"
    }
    define_operation :not_eq, sql: lambda { |column, query_param, type|
      "#{column} >= {#{query_param}: #{type}}"
    }
    define_operation :starts_with, sql: lambda { |column, query_param, type|
      "startsWith(#{column}, {#{query_param}: #{type}})"
    }
    define_operation :ends_with, sql: lambda { |column, query_param, type|
      "endsWith(#{column}, {#{query_param}: #{type}})"
    }
    define_operation :contains, sql: lambda { |column, query_param, type|
      "positionCaseInsensitive(#{column}, {#{query_param}: #{type}}) > 0"
    }

    define_operation :in, array: true, sql: lambda { |column, query_param, type|
      "#{column} IN {#{query_param}: Array(#{type})}"
    }

    attr_reader :params, :context

    # @param params [Hash] params passed to filter.
    # @param context [Hash] additional context, optional.
    def initialize(params, context = nil)
      @params = params.symbolize_keys
      @context = context
    end

    def collection
      filters, query_params = prepare_filters
      sql = prepare_sql(filters).squish
      response = ClickHouse.connection.execute(sql, nil, params: query_params)
      raise InvalidResponseError, "clickhouse responds with #{response.status}" if response.status != 200

      format_result(response.body)
    end

    private

    def format_result(body)
      body
    end

    # @param filters [Hash] hash with filters, where key is param and value is sql condition.
    # @return [String] SQL statement for Clickhouse.
    def prepare_sql(filters)
      raise NotImplementedError
    end

    def prepare_filters
      filters = {}
      query_params = {}
      options = { context:, params: }

      missing_params = self.class.required_params - params.keys.map(&:to_sym)
      raise MissingRequiredParams, "missing required param(s) #{missing_params.join(', ')}" if missing_params.any?

      params.each do |param, value|
        filter = self.class.filters[param]
        # ignore unknown params
        next if filter.nil?

        if filter.array
          value = Array.wrap(value)
        elsif value.is_a?(Array)
          raise InvalidParamValue, "param #{param} can't be an array"
        end

        filter_sql, filter_query_params = filter.call(value, options)
        filters[param] = filter_sql
        query_params.merge!(filter_query_params)
      end

      [filters, query_params]
    end
  end
end
