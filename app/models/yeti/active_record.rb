class Yeti::ActiveRecord < ActiveRecord::Base

  self.abstract_class = true

  def self.array_belongs_to(name, class_name:, foreign_key:)
    define_method(name) do
      relation = class_name.is_a?(String) ? class_name.constantize : class_name
      ids = self.public_send(foreign_key)
      relation_collection = relation.where(id: ids).to_a
      if ids.include?(nil)
        relation_collection.push(relation.new(name: Routing::RoutingTag::ANY_TAG))
      end
      relation_collection
    end
  end

  def self.db_version
    self.fetch_sp_val("select max(version) from public.schema_migrations")
  end


  def table_full_size
    fetch_sp_val("SELECT pg_total_relation_size(?)", self.name)
  end

  def table_data_size
    fetch_sp_val("SELECT pg_relation_size(?)", self.name)
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

  #clone methods for isntance objects
  [:execute_sp, :fetch_sp, :fetch_sp_val].each do |method|
    define_method method   do |*args|
      self.class.send(method, *args)
    end
  end


  def self.perform_sp(method, sql, *bindings)
    if bindings.any?
      sql = self.send(:sanitize_sql_array, bindings.unshift(sql))
    end
    self.connection.send(method, sql)
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
      limit 10").to_hash
  end

  def self.db_size
    fetch_sp_val("SELECT pg_size_pretty(pg_database_size(current_database()))")
  end

  DB_VER = LazyObject.new { db_version }
  ROUTING_SCHEMA="switch16"

  PG_MAX_INT = 2147483647
  PG_MIN_INT = 2147483647

  PG_MAX_SMALLINT = 32767
  PG_MIN_SMALLINT = -32768

  L4_PORT_MIN = 1
  L4_PORT_MAX = 65535

end
