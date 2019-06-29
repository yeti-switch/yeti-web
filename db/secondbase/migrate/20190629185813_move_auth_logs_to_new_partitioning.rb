class MoveAuthLogsToNewPartitioning < ActiveRecord::Migration[5.2]
  def up
    parent_table = 'auth_log.auth_log'
    trigger_name = 'auth_log_i'
    function_name = 'auth_log.auth_log_i_tgf'
    sequence_name = 'auth_log.auth_log_id_seq'
    control_table = 'sys.auth_log_tables'

    partitions = SqlCaller::Yeti.select_all_serialized <<-SQL
      SELECT name, date_start, date_stop
      FROM #{control_table};
    SQL

    # detach partitions from parent/archive tables
    partitions.each do |partition|
      table_name = partition[:name]
      execute <<-SQL
        -- detach partitions from parent/archive tables
        ALTER TABLE #{table_name} NO INHERIT #{parent_table};

        -- remove id default
        ALTER TABLE #{table_name} ALTER COLUMN id DROP DEFAULT;
      SQL
    end

    # drop trigger function
    execute <<-SQL
      DROP TRIGGER #{trigger_name} ON #{parent_table};
      DROP FUNCTION #{function_name}();
    SQL

    # save last id for parent table
    last_value = select_value <<-SQL
      SELECT last_value FROM #{sequence_name};
    SQL

    # drop parent table
    execute <<-SQL
      DROP TABLE #{parent_table};
    SQL

    # create parent table with indexes
    execute <<-SQL
      CREATE TABLE #{parent_table} (
          id bigint NOT NULL,
          node_id smallint,
          pop_id smallint,
          request_time timestamp with time zone NOT NULL,
          transport_proto_id smallint,
          transport_remote_ip character varying,
          transport_remote_port integer,
          transport_local_ip character varying,
          transport_local_port integer,
          origination_ip character varying,
          origination_port integer,
          origination_proto_id smallint,
          username character varying,
          realm character varying,
          request_method character varying,
          ruri character varying,
          from_uri character varying,
          to_uri character varying,
          call_id character varying,
          success boolean,
          code smallint,
          reason character varying,
          internal_reason character varying,
          nonce character varying,
          response character varying,
          gateway_id integer,
          x_yeti_auth character varying,
          diversion character varying,
          pai character varying,
          ppi character varying,
          privacy character varying,
          rpid character varying,
          rpid_privacy character varying

      ) PARTITION BY RANGE (request_time);

      CREATE SEQUENCE #{sequence_name} AS bigint START WITH #{last_value} OWNED BY #{parent_table}.id;
      ALTER TABLE #{parent_table} ALTER COLUMN id SET DEFAULT nextval('#{sequence_name}'::regclass);
    SQL

    execute <<-SQL
      -- primary key for id and request_time
      ALTER TABLE ONLY #{parent_table} ADD CONSTRAINT auth_log_pkey PRIMARY KEY (id, request_time);

      -- indexes
      CREATE INDEX auth_log_id_idx ON #{parent_table} USING btree (id);
      CREATE INDEX auth_log_request_time_idx ON #{parent_table} USING btree (request_time);
    SQL

    partitions.each do |partition|
      table_name = partition[:name]
      t_name = table_name.split('.').last
      date_start = partition[:date_start]
      date_stop = partition[:date_stop]

      execute <<-SQL
        -- attach partitions to new parent table
        ALTER TABLE #{parent_table} ATTACH PARTITION #{table_name}
          FOR VALUES FROM ('#{date_start}') TO ('#{date_stop}');

        -- drop constraint from old partitioning
        ALTER TABLE #{table_name} DROP CONSTRAINT #{t_name}_request_time_check;

        -- attach index for request_time column
        ALTER INDEX auth_log.auth_log_request_time_idx ATTACH PARTITION auth_log."index_auth_log.#{t_name}_on_request_time";
      SQL
    end

    # drop control table
    execute <<-SQL
      DROP TABLE #{control_table};
    SQL
  end

  def down
    # nothing
  end

  private

  def select_all_serialized(sql, *bindings)
    result = select_all(sql, *bindings)
    result.map { |row| row.map { |k, v| [k.to_sym, result.column_types[k].deserialize(v)] }.to_h }
  end
end
