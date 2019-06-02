# frozen_string_literal: true

module SqlCaller
  class Base
    include Singleton
    extend SingleForwardable

    class_attribute :_model_name, instance_writer: false

    CONNECTION_METHODS = %i[
      select_value
      select_values
      execute
      select_all
      select_rows
    ].freeze

    class << self
      def model_name(class_name)
        self._model_name = class_name.to_s
      end

      def delegate_connection_methods(*names)
        names.each { |name| delegate_connection_method(name) }
      end

      def delegate_connection_method(name)
        define_method(name) { |sql, *args| perform_sp(name, sql, *args) }
        def_delegators :instance, name
      end

      def define_custom_method(name, &block)
        define_method(name) { |*args| instance_exec(*args, &block) }
        def_delegators :instance, name
      end
    end

    delegate_connection_methods(*CONNECTION_METHODS)

    define_custom_method(:select_row) do |sql, *bindings|
      select_rows(sql, *bindings)[0]
    end

    define_custom_method(:select_all_serialized) do |sql, *bindings|
      result = select_all(sql, *bindings)
      result.map { |row| row.map { |key, value| [key.to_sym, deserialize(result, key, value)] }.to_h }
    end

    define_custom_method(:set_timezone) do |value|
      execute("SET TIME ZONE #{quote(value)};")
    end

    define_custom_method(:current_timezone) do
      select_value("SELECT current_setting('TIMEZONE');")
    end

    private

    def quote(value)
      connection.quote(value)
    end

    def deserialize(result, key, value)
      result.column_types[key].deserialize(value)
    end

    def model_class
      return @model_class if defined?(@model_class)
      raise NotImplementedError, 'define model_class via #model_name class method' if _model_name.nil?

      @model_class = _model_name.constantize
    end

    def connection
      model_class.connection
    end

    def sanitize_sql_array(sql, *bindings)
      model_class.send :sanitize_sql_array, bindings.unshift(sql)
    end

    def perform_sp(method, sql, *bindings)
      sql = sanitize_sql_array(sql, *bindings) if bindings.any?
      connection.send(method, sql)
    end
  end
end
