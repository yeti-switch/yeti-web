# frozen_string_literal: true

module SqlCaller
  class Base < PgSqlCaller::Base
    class << self
      def define_custom_method(name, &block)
        define_method(name) { |*args| instance_exec(*args, &block) }
        delegate name, to: :instance, type: :single
      end
    end

    define_custom_method(:set_timezone) do |value|
      execute("SET TIME ZONE #{quote(value)};")
    end

    define_custom_method(:current_timezone) do
      select_value("SELECT current_setting('TIMEZONE');")
    end

    define_custom_method(:select_line_serialized) do |sql, *bindings|
      select_all_serialized(sql, *bindings).first
    end

    define_custom_method(:table_exist?) do |table_name|
      query = <<-SQL
        SELECT COUNT(*)
        FROM information_schema.tables
        WHERE table_schema||'.'||table_name = ?
      SQL
      count = select_value(query, table_name)
      count > 0
    end

    define_custom_method(:table_size) do |table_names|
      query = <<-SQL
        SELECT
          table_schema||'.'||table_name AS name,
          pg_size_pretty(
            pg_relation_size(quote_ident(table_schema)||'.'||quote_ident(table_name))
          ) AS size,
          pg_size_pretty(
            pg_total_relation_size(quote_ident(table_schema)||'.'||quote_ident(table_name))
          ) AS total_size
        FROM information_schema.tables
        WHERE table_schema||'.'||table_name IN (?)
      SQL
      select_all_serialized(query, table_names)
    end

    define_custom_method(:approximate_row_count) do |table_names|
      query = <<-SQL
        SELECT
          sch.nspname||'.'||tbl.relname AS name,
          tbl.reltuples AS approximate_row_count
        FROM pg_class tbl
        JOIN pg_namespace sch ON sch.oid = tbl.relnamespace
        WHERE sch.nspname||'.'||tbl.relname IN (?)
      SQL
      select_all_serialized(query, table_names)
    end

    private

    def quote(value)
      connection.quote(value)
    end
  end
end
