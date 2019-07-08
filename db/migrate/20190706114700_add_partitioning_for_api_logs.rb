class AddPartitioningForApiLogs < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      DROP TABLE logs.api_requests;
    SQL

    execute <<-SQL
      CREATE TABLE logs.api_requests (
          id bigint NOT NULL,
          created_at timestamp with time zone DEFAULT now() NOT NULL,
          path character varying,
          method character varying,
          status integer,
          controller character varying,
          action character varying,
          page_duration real,
          db_duration real,
          params text,
          request_body text,
          response_body text,
          request_headers text,
          response_headers text
      ) PARTITION BY RANGE (created_at);
    SQL

    execute <<-SQL
      CREATE SEQUENCE logs.api_requests_id_seq
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        NO MAXVALUE
        CACHE 1
        OWNED BY logs.api_requests.id;

      ALTER TABLE ONLY logs.api_requests 
        ALTER COLUMN id SET DEFAULT nextval('logs.api_requests_id_seq'::regclass);
    SQL

    execute <<-SQL
      ALTER TABLE ONLY logs.api_requests ADD CONSTRAINT api_requests_pkey PRIMARY KEY (id, created_at);
      CREATE INDEX api_requests_id_idx ON logs.api_requests USING btree (id);
      CREATE INDEX api_requests_created_at_idx ON logs.api_requests USING btree (created_at);
    SQL

    Log::ApiLog.add_partitions
  end

  def down
    execute <<-SQL
      DROP TABLE logs.api_requests;
    SQL

    execute <<-SQL
      CREATE TABLE logs.api_requests (
          id bigint PRIMARY KEY,
          created_at timestamp with time zone DEFAULT now() NOT NULL,
          path character varying,
          method character varying,
          status integer,
          controller character varying,
          action character varying,
          page_duration real,
          db_duration real,
          params text,
          request_body text,
          response_body text,
          request_headers text,
          response_headers text
      );

      CREATE INDEX api_requests_created_at_idx ON logs.api_requests USING btree (created_at);
    SQL
  end
end
