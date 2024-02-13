# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  connects_to database: { writing: :primary, reading: :primary }
  include WithJsonAttributes

  def self.array_belongs_to(name, class_name:, foreign_key:)
    define_method(name) do
      relation = class_name.is_a?(String) ? class_name.constantize : class_name
      ids = public_send(foreign_key)
      relation_collection = relation.where(id: ids).to_a
      if ids.include?(nil)
        relation_collection.push(relation.new(name: Routing::RoutingTag::ANY_TAG))
      end
      relation_collection
    end
  end

  def self.db_version
    fetch_sp_val('select max(version) from public.schema_migrations')
  end

  def table_full_size
    fetch_sp_val('SELECT pg_total_relation_size(?)', name)
  end

  def table_data_size
    fetch_sp_val('SELECT pg_relation_size(?)', name)
  end

  def self.ransackable_attributes(_auth_object = nil)
    @ransackable_attributes ||= authorizable_ransackable_attributes
  end

  def self.ransackable_associations(_auth_object = nil)
    @ransackable_associations ||= authorizable_ransackable_associations
  end

  def self.execute_sp(sql, *bindings)
    perform_sp(:execute, sql, *bindings)
  end

  def self.fetch_sp(sql, *bindings)
    perform_sp(:select_all, sql, *bindings)
  end

  def self.fetch_sp_val(sql, *bindings)
    perform_sp(:select_value, sql, *bindings)
  end

  # clone methods for instance objects
  %i[execute_sp fetch_sp fetch_sp_val].each do |method|
    define_method method   do |*args|
      self.class.send(method, *args)
    end
  end

  def self.perform_sp(method, sql, *bindings)
    sql = send(:sanitize_sql_array, bindings.unshift(sql)) if bindings.any?
    connection.send(method, sql)
  end

  def self.top_tables
    fetch_sp("
      select
        table_schema,
        table_name,
        pg_size_pretty(size) as data_size,
        pg_size_pretty(total_size) as total_size
      from (
        (select table_schema, table_name, pg_relation_size( quote_ident( table_schema ) || '.' || quote_ident( table_name ) ) as size,
        pg_total_relation_size( quote_ident( table_schema ) || '.' || quote_ident( table_name ) ) as total_size
        from information_schema.tables
        where
          table_type = 'BASE TABLE' and
          table_schema not in ('information_schema', 'pg_catalog')
        order by pg_relation_size( quote_ident( table_schema ) || '.' || quote_ident( table_name ) ) desc, table_schema, table_name)
      ) x
      order by x.total_size desc, x.size desc, table_schema, table_name
      limit 10").to_ary.map(&:deep_symbolize_keys!)
  end

  def self.db_size
    fetch_sp_val('SELECT pg_size_pretty(pg_database_size(current_database()))')
  end

  # @param name [Symbol]
  # @param id_column [Symbol]
  # @param allowed_values [Hash<Integer, String>] id_column_value => value
  def self.define_enum_scopes(name:, id_column: nil, allowed_values:)
    id_column ||= :"#{name}_id"

    scope :"#{name}_eq", lambda { |value|
      id_column_value = allowed_values.key(value)
      id_column_value ? where(id_column => id_column_value) : none
    }

    scope :"#{name}_not_eq", lambda { |value|
      id_column_value = allowed_values.key(value)
      id_column_value ? where.not(id_column => id_column_value) : all
    }

    scope :"#{name}_in", lambda { |*values|
      id_column_values = values.map { |val| allowed_values.key(val) }.compact
      id_column_values.present? ? where(id_column => id_column_values) : none
    }

    scope :"#{name}_not_in", lambda { |*values|
      id_column_values = values.map { |val| allowed_values.key(val) }.compact
      id_column_values.present? ? where.not(id_column => id_column_values) : all
    }
  end

  def self.enum_scope_names(name)
    [:"#{name}_eq", :"#{name}_not_eq", :"#{name}_in", :"#{name}_not_in"]
  end

  DB_VER = LazyObject.new { db_version }
  ROUTING_SCHEMA = 'switch20'

  PG_MAX_INT = 2_147_483_647
  PG_MIN_INT = -2_147_483_647

  PG_MAX_SMALLINT = 32_767
  PG_MIN_SMALLINT = -32_768

  L4_PORT_MIN = 1
  L4_PORT_MAX = 65_535
end
