# frozen_string_literal: true

module CallSql
  class Base
    include Singleton
    extend SingleForwardable

    AVAILABLE_METHODS = %i[select_value select_values execute select_all select_rows].freeze

    def self._define_sql_method(name)
      define_method(name) do |sql, *args|
        perform_sp(name, sql, *args)
      end
    end

    def self._delegate_to_instance(*names)
      def_delegators :instance, *names
    end

    AVAILABLE_METHODS.each do |name|
      _define_sql_method(name)
    end

    def select_row(sql, *bindings)
      select_rows(sql, *bindings)[0]
    end

    def select_all_serialized(sql, *bindings)
      result = select_all(sql, *bindings)
      result.map { |row| row.map { |k, v| [k.to_sym, result.column_types[k].deserialize(v)] }.to_h }
    end

    _delegate_to_instance(:select_row, :select_all_serialized, *AVAILABLE_METHODS)

    private

    def model_klass
      raise NotImplementedError, 'method #model_klass must be defined'
    end

    def connection
      model_klass.connection
    end

    def sanitize_sql_array(sql, *bindings)
      model_klass.send :sanitize_sql_array, bindings.unshift(sql)
    end

    def perform_sp(method, sql, *bindings)
      sql = sanitize_sql_array(sql, *bindings) if bindings.any?
      connection.send(method, sql)
    end
  end
end
