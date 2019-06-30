# frozen_string_literal: true

class MoveCdrsToNewPartitioning < ActiveRecord::Migration[5.2]
  def up
    parent_table = 'cdr.cdr'
    archive_table = 'cdr.cdr_archive'
    trigger_name = 'cdr_i'
    function_name = 'cdr.cdr_i_tgf'
    sequence_name = 'cdr.cdr_id_seq'
    control_table = 'sys.cdr_tables'

    partitions = SqlCaller::Yeti.select_all_serialized <<-SQL
      SELECT name, date_start, date_stop, active
      FROM #{control_table};
    SQL

    # detach partitions from parent/archive tables
    partitions.each do |partition|
      table_name = partition[:name]
      base_table = partition[:active] ? parent_table : archive_table
      execute <<-SQL
        -- detach partitions from parent/archive tables
        ALTER TABLE #{table_name} NO INHERIT #{base_table};

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

    # drop functions that depends on parent table
    execute <<-SQL
      DROP FUNCTION billing.bill_cdr(cdr.cdr);
      DROP FUNCTION stats.update_rt_stats(cdr.cdr);
    SQL

    # drop parent table and archive table
    execute <<-SQL
      DROP TABLE #{parent_table};
      DROP TABLE #{archive_table};
    SQL

    # create parent table with indexes
    execute <<-SQL
      CREATE TABLE cdr.cdr (
          id bigint NOT NULL,
          customer_id integer,
          vendor_id integer,
          customer_acc_id integer,
          vendor_acc_id integer,
          customer_auth_id integer,
          destination_id integer,
          dialpeer_id integer,
          orig_gw_id integer,
          term_gw_id integer,
          routing_group_id integer,
          rateplan_id integer,
          destination_next_rate numeric,
          destination_fee numeric,
          dialpeer_next_rate numeric,
          dialpeer_fee numeric,
          time_limit character varying,
          internal_disconnect_code integer,
          internal_disconnect_reason character varying,
          disconnect_initiator_id integer,
          customer_price numeric,
          vendor_price numeric,
          duration integer,
          success boolean,
          profit numeric,
          dst_prefix_in character varying,
          dst_prefix_out character varying,
          src_prefix_in character varying,
          src_prefix_out character varying,
          time_start timestamp with time zone NOT NULL, -- added NOT NULL
          time_connect timestamp with time zone,
          time_end timestamp with time zone,
          sign_orig_ip character varying,
          sign_orig_port integer,
          sign_orig_local_ip character varying,
          sign_orig_local_port integer,
          sign_term_ip character varying,
          sign_term_port integer,
          sign_term_local_ip character varying,
          sign_term_local_port integer,
          orig_call_id character varying,
          term_call_id character varying,
          vendor_invoice_id integer,
          customer_invoice_id integer,
          local_tag character varying,
          destination_initial_rate numeric,
          dialpeer_initial_rate numeric,
          destination_initial_interval integer,
          destination_next_interval integer,
          dialpeer_initial_interval integer,
          dialpeer_next_interval integer,
          destination_rate_policy_id integer,
          routing_attempt integer,
          is_last_cdr boolean,
          lega_disconnect_code integer,
          lega_disconnect_reason character varying,
          pop_id integer,
          node_id integer,
          src_name_in character varying,
          src_name_out character varying,
          diversion_in character varying,
          diversion_out character varying,
          lega_rx_payloads character varying,
          lega_tx_payloads character varying,
          legb_rx_payloads character varying,
          legb_tx_payloads character varying,
          legb_disconnect_code integer,
          legb_disconnect_reason character varying,
          dump_level_id integer DEFAULT 0 NOT NULL,
          auth_orig_ip inet,
          auth_orig_port integer,
          lega_rx_bytes integer,
          lega_tx_bytes integer,
          legb_rx_bytes integer,
          legb_tx_bytes integer,
          global_tag character varying,
          dst_country_id integer,
          dst_network_id integer,
          lega_rx_decode_errs integer,
          lega_rx_no_buf_errs integer,
          lega_rx_parse_errs integer,
          legb_rx_decode_errs integer,
          legb_rx_no_buf_errs integer,
          legb_rx_parse_errs integer,
          src_prefix_routing character varying,
          dst_prefix_routing character varying,
          routing_plan_id integer,
          routing_delay double precision,
          pdd double precision,
          rtt double precision,
          early_media_present boolean,
          lnp_database_id smallint,
          lrn character varying,
          destination_prefix character varying,
          dialpeer_prefix character varying,
          audio_recorded boolean,
          ruri_domain character varying,
          to_domain character varying,
          from_domain character varying,
          src_area_id integer,
          dst_area_id integer,
          auth_orig_transport_protocol_id smallint,
          sign_orig_transport_protocol_id smallint,
          sign_term_transport_protocol_id smallint,
          core_version character varying,
          yeti_version character varying,
          lega_user_agent character varying,
          legb_user_agent character varying,
          uuid uuid,
          pai_in character varying,
          ppi_in character varying,
          privacy_in character varying,
          rpid_in character varying,
          rpid_privacy_in character varying,
          pai_out character varying,
          ppi_out character varying,
          privacy_out character varying,
          rpid_out character varying,
          rpid_privacy_out character varying,
          destination_reverse_billing boolean,
          dialpeer_reverse_billing boolean,
          is_redirected boolean,
          customer_account_check_balance boolean,
          customer_external_id bigint,
          customer_auth_external_id bigint,
          customer_acc_vat numeric,
          customer_acc_external_id bigint,
          routing_tag_ids smallint[],
          vendor_external_id bigint,
          vendor_acc_external_id bigint,
          orig_gw_external_id bigint,
          term_gw_external_id bigint,
          failed_resource_type_id smallint,
          failed_resource_id bigint,
          customer_price_no_vat numeric,
          customer_duration integer,
          vendor_duration integer,
          customer_auth_name character varying,
          legb_local_tag character varying

      ) PARTITION BY RANGE (time_start);

      CREATE SEQUENCE #{sequence_name} AS bigint START WITH #{last_value} OWNED BY cdr.cdr.id;
      ALTER TABLE cdr.cdr ALTER COLUMN id SET DEFAULT nextval('#{sequence_name}'::regclass);
    SQL

    execute <<-SQL
      -- unique index for id and time_start instead of primary key
      -- CREATE UNIQUE INDEX cdr_id_time_start_idx ON cdr.cdr USING btree (id, time_start);
      -- primary key for id and time_start
      ALTER TABLE ONLY cdr.cdr ADD CONSTRAINT cdr_pkey PRIMARY KEY (id, time_start);

      -- indexes migrated from old table definition
      CREATE INDEX cdr_id_idx ON cdr.cdr USING btree (id);
      CREATE INDEX cdr_time_start_idx ON cdr.cdr USING btree (time_start);
      CREATE INDEX cdr_vendor_invoice_id_idx ON cdr.cdr USING btree (vendor_invoice_id);
    SQL

    partitions.each do |partition|
      table_name = partition[:name]
      t_name = table_name.split('.').last
      date_start = partition[:date_start]
      date_stop = partition[:date_stop]

      execute <<-SQL
        -- set time_start not null for partitions
        ALTER TABLE #{table_name}
          ALTER COLUMN time_start SET NOT NULL;

        -- attach partitions to new parent table
        ALTER TABLE #{parent_table} ATTACH PARTITION #{table_name}
          FOR VALUES FROM ('#{date_start}') TO ('#{date_stop}');

        -- drop constraint from old partitioning
        ALTER TABLE #{table_name} DROP CONSTRAINT #{t_name}_time_start_check;

        -- attach index for time_start column
        ALTER INDEX cdr.cdr_time_start_idx ATTACH PARTITION cdr."index_cdr.#{t_name}_on_time_start";
      SQL
    end

    # recreate functions
    execute <<~SQL
            CREATE FUNCTION billing.bill_cdr(i_cdr cdr.cdr) RETURNS cdr.cdr
            LANGUAGE plpgsql COST 10
            AS $$
      DECLARE
          _v billing.interval_billing_data%rowtype;
      BEGIN
          if i_cdr.duration>0 and i_cdr.success then  -- run billing.
              _v=billing.interval_billing(
                  i_cdr.duration,
                  i_cdr.destination_fee,
                  i_cdr.destination_initial_rate,
                  i_cdr.destination_next_rate,
                  i_cdr.destination_initial_interval,
                  i_cdr.destination_next_interval,
                  i_cdr.customer_acc_vat);
               i_cdr.customer_price=_v.amount;
               i_cdr.customer_price_no_vat=_v.amount_no_vat;
               i_cdr.customer_duration=_v.duration;

               _v=billing.interval_billing(
                  i_cdr.duration,
                  i_cdr.dialpeer_fee,
                  i_cdr.dialpeer_initial_rate,
                  i_cdr.dialpeer_next_rate,
                  i_cdr.dialpeer_initial_interval,
                  i_cdr.dialpeer_next_interval,
                  0);
               i_cdr.vendor_price=_v.amount;
               i_cdr.vendor_duration=_v.duration;
               i_cdr.profit=i_cdr.customer_price-i_cdr.vendor_price;
          else
              i_cdr.customer_price=0;
              i_cdr.customer_price_no_vat=0;
              i_cdr.vendor_price=0;
              i_cdr.profit=0;
          end if;
          RETURN i_cdr;
      END;
      $$;

            CREATE FUNCTION stats.update_rt_stats(i_cdr cdr.cdr) RETURNS void
            LANGUAGE plpgsql COST 10
            AS $$
      DECLARE
          v_agg_period varchar:='minute';
          v_ts timestamp;
          v_profit numeric;

      BEGIN
          if i_cdr.customer_acc_id is null or i_cdr.customer_acc_id=0 then
              return;
          end if;
          v_ts=date_trunc(v_agg_period,i_cdr.time_start);
          v_profit=coalesce(i_cdr.profit,0);

          update stats.traffic_customer_accounts set
              duration=duration+coalesce(i_cdr.duration,0),
              count=count+1,
              amount=amount+coalesce(i_cdr.customer_price),
              profit=profit+v_profit
          where account_id=i_cdr.customer_acc_id and timestamp=v_ts;
          if not found then
              begin
                  insert into stats.traffic_customer_accounts(timestamp,account_id,duration,count,amount,profit)
                      values(v_ts,i_cdr.customer_acc_id,coalesce(i_cdr.duration,0),1,coalesce(i_cdr.customer_price),v_profit);
              exception
                  when unique_violation then
                      update stats.traffic_customer_accounts set
                          duration=duration+coalesce(i_cdr.duration,0),
                          count=count+1,
                          amount=amount+coalesce(i_cdr.customer_price),
                          profit=profit+v_profit
                      where account_id=i_cdr.customer_acc_id and timestamp=v_ts;
              end;
          end if;



          if i_cdr.vendor_acc_id is null or i_cdr.vendor_acc_id=0 then
              return;
          end if;
          update stats.traffic_vendor_accounts set
              duration=duration+coalesce(i_cdr.duration,0),
              count=count+1,
              amount=amount+coalesce(i_cdr.vendor_price),
              profit=profit+v_profit
          where account_id=i_cdr.vendor_acc_id and timestamp=v_ts;
          if not found then
              begin
                  insert into stats.traffic_vendor_accounts(timestamp,account_id,duration,count,amount,profit)
                      values(v_ts,i_cdr.vendor_acc_id,coalesce(i_cdr.duration,0),1,coalesce(i_cdr.vendor_price),v_profit);
              exception
                  when unique_violation then
                      update stats.traffic_vendor_accounts set
                          duration=duration+coalesce(i_cdr.duration,0),
                          count=count+1,
                          amount=amount+coalesce(i_cdr.vendor_price),
                          profit=profit+v_profit
                      where account_id=i_cdr.vendor_acc_id and timestamp=v_ts;
              end;
          end if;

          insert into stats.termination_quality_stats(dialpeer_id,destination_id, gateway_id,time_start,success,duration,pdd,early_media_present)
              values(i_cdr.dialpeer_id, i_cdr.destination_id, i_cdr.term_gw_id, i_cdr.time_start, i_cdr.success, i_cdr.duration, i_cdr.pdd, i_cdr.early_media_present);


          RETURN ;
      END;
      $$;
    SQL

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
