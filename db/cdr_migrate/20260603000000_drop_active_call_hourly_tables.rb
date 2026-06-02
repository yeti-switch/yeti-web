# frozen_string_literal: true

class DropActiveCallHourlyTables < ActiveRecord::Migration[7.2]
  # The hourly rollup of active-call stats was removed. Raw per-minute stats are
  # now retained for a month and reduced client-side, so these aggregate tables
  # are no longer populated or read.
  HOURLY_TABLES = %w[
    stats.active_calls_hourly
    stats.active_call_accounts_hourly
    stats.active_call_orig_gateways_hourly
    stats.active_call_term_gateways_hourly
  ].freeze

  def up
    HOURLY_TABLES.each do |table|
      execute "DROP TABLE IF EXISTS #{table};"
    end
  end

  def down
    execute <<~SQL
      CREATE TABLE stats.active_calls_hourly (
          id bigint NOT NULL,
          node_id integer NOT NULL,
          max_count integer NOT NULL,
          avg_count real NOT NULL,
          min_count integer NOT NULL,
          created_at timestamp with time zone NOT NULL,
          calls_time timestamp with time zone NOT NULL
      );
      CREATE SEQUENCE stats.active_calls_hourly_id_seq
          START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
      ALTER SEQUENCE stats.active_calls_hourly_id_seq OWNED BY stats.active_calls_hourly.id;
      ALTER TABLE ONLY stats.active_calls_hourly ALTER COLUMN id SET DEFAULT nextval('stats.active_calls_hourly_id_seq'::regclass);
      ALTER TABLE ONLY stats.active_calls_hourly ADD CONSTRAINT active_calls_hourly_pkey PRIMARY KEY (id);

      CREATE TABLE stats.active_call_accounts_hourly (
          id bigint NOT NULL,
          account_id integer NOT NULL,
          max_originated_count integer NOT NULL,
          avg_originated_count integer NOT NULL,
          min_originated_count integer NOT NULL,
          max_terminated_count integer NOT NULL,
          avg_terminated_count integer NOT NULL,
          min_terminated_count integer NOT NULL,
          created_at timestamp with time zone NOT NULL,
          calls_time timestamp with time zone NOT NULL
      );
      CREATE SEQUENCE stats.active_call_accounts_hourly_id_seq
          START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
      ALTER SEQUENCE stats.active_call_accounts_hourly_id_seq OWNED BY stats.active_call_accounts_hourly.id;
      ALTER TABLE ONLY stats.active_call_accounts_hourly ALTER COLUMN id SET DEFAULT nextval('stats.active_call_accounts_hourly_id_seq'::regclass);
      ALTER TABLE ONLY stats.active_call_accounts_hourly ADD CONSTRAINT active_call_accounts_hourly_pkey PRIMARY KEY (id);

      CREATE TABLE stats.active_call_orig_gateways_hourly (
          id bigint NOT NULL,
          gateway_id integer NOT NULL,
          max_count integer NOT NULL,
          avg_count real NOT NULL,
          min_count integer NOT NULL,
          created_at timestamp with time zone NOT NULL,
          calls_time timestamp with time zone NOT NULL
      );
      CREATE SEQUENCE stats.active_call_orig_gateways_hourly_id_seq
          START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
      ALTER SEQUENCE stats.active_call_orig_gateways_hourly_id_seq OWNED BY stats.active_call_orig_gateways_hourly.id;
      ALTER TABLE ONLY stats.active_call_orig_gateways_hourly ALTER COLUMN id SET DEFAULT nextval('stats.active_call_orig_gateways_hourly_id_seq'::regclass);
      ALTER TABLE ONLY stats.active_call_orig_gateways_hourly ADD CONSTRAINT active_call_orig_gateways_hourly_pkey PRIMARY KEY (id);

      CREATE TABLE stats.active_call_term_gateways_hourly (
          id bigint NOT NULL,
          gateway_id integer NOT NULL,
          max_count integer NOT NULL,
          avg_count real NOT NULL,
          min_count integer NOT NULL,
          created_at timestamp with time zone NOT NULL,
          calls_time timestamp with time zone NOT NULL
      );
      CREATE SEQUENCE stats.active_call_term_gateways_hourly_id_seq
          START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
      ALTER SEQUENCE stats.active_call_term_gateways_hourly_id_seq OWNED BY stats.active_call_term_gateways_hourly.id;
      ALTER TABLE ONLY stats.active_call_term_gateways_hourly ALTER COLUMN id SET DEFAULT nextval('stats.active_call_term_gateways_hourly_id_seq'::regclass);
      ALTER TABLE ONLY stats.active_call_term_gateways_hourly ADD CONSTRAINT active_call_term_gateways_hourly_pkey PRIMARY KEY (id);
    SQL
  end
end
