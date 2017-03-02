begin;
insert into sys.version(number,comment) values(21,'LNP configuration and billing fixes');

alter table cdr.cdr
  add lnp_database_id SMALLINT,
  add lrn varchar,
  add destination_prefix varchar,
  add dialpeer_prefix varchar;

alter table cdr.cdr_archive
  add lnp_database_id SMALLINT,
  add lrn varchar,
  add destination_prefix varchar,
  add dialpeer_prefix varchar;

-- TODO Store to cdr destination_id/prefix + dialpeer_id/prefix. We need this to Invoice details generation

create table stats.termination_quality_stats(
  id bigserial PRIMARY KEY,
  dialpeer_id bigint not null,
  gateway_id int not null,
  time_start TIMESTAMPTZ not null,
  success boolean not null,
  duration bigint not null
);

DROP FUNCTION billing.invoice_remove(integer);


-- Function: billing.invoice_generate(integer, integer, boolean, timestamp with time zone, timestamp with time zone)

-- DROP FUNCTION billing.invoice_generate(integer, integer, boolean, timestamp with time zone, timestamp with time zone);

CREATE OR REPLACE FUNCTION billing.invoice_generate(
  i_contractor_id integer,
  i_account_id integer,
  i_vendor_flag boolean,
  i_startdate timestamp with time zone,
  i_enddate timestamp with time zone)
  RETURNS integer AS
  $BODY$
DECLARE
v_id integer;
v_amount numeric;
v_count bigint;
v_min_date timestamp;
v_max_date timestamp;
v_sql varchar;
BEGIN
    if i_startdate is null then
        select into i_startdate end_date from billing.invoices where account_id=i_account_id order by end_date desc limit 1;
        if not found then
            RAise exception 'Can''t detect date start';
        end if;
    end if;

    INSERT into billing.invoices(contractor_id,account_id,start_date,end_date,amount,vendor_invoice,calls_count)
        VALUES(i_contractor_id,i_account_id,i_startdate,i_enddate,0,i_vendor_flag,0) RETURNING id INTO v_id;


        if i_vendor_flag THEN -- IF vendor
                PERFORM * FROM cdr.cdr WHERE vendor_acc_id =i_account_id AND time_start>=i_startdate AND time_end<i_enddate AND vendor_invoice_id IS NOT NULL;
                IF FOUND THEN
                        RAISE EXCEPTION 'billing.invoice_generate: some vendor invoices already found for this interval';
                END IF;
                execute format('UPDATE cdr.cdr SET vendor_invoice_id=%L
                    WHERE vendor_acc_id =%L AND time_start>=%L AND time_end<%L AND vendor_invoice_id IS NULL', v_id, i_account_id, i_startdate, i_enddate);

                execute format('insert into billing.invoice_destinations(
                    dst_prefix,country_id,network_id,rate,calls_count,calls_duration,amount,invoice_id,first_call_at,last_call_at
                    ) select  dialpeer_prefix,
                            dst_country_id,
                            dst_network_id,
                            dialpeer_next_rate,
                            count(nullif(is_last_cdr,false)),
                            sum(duration),
                            sum(vendor_price),
                            %L,
                            min(time_start),
                            max(time_start)
                    from cdr.cdr
                    where vendor_acc_id =%L AND time_start>=%L AND time_end<%L AND vendor_invoice_id =%L
                    group by dialpeer_prefix, dst_country_id, dst_network_id, dialpeer_next_rate', v_id, i_account_id, i_startdate, i_enddate, v_id);

                SELECT INTO v_count, v_amount, v_min_date, v_max_date
                    coalesce(sum(calls_count),0),
                    COALESCE(sum(amount),0),
                    min(first_call_at),
                    max(last_call_at)
                    from billing.invoice_destinations
                    where invoice_id =v_id;

                RAISE NOTICE 'wer % - %',v_count,v_amount;

                UPDATE billing.invoices SET amount=v_amount,calls_count=v_count,first_call_date=v_min_date,last_call_date=v_max_date WHERE id=v_id;
        ELSE -- customer invoice generation
                PERFORM * FROM cdr.cdr WHERE customer_acc_id =i_account_id AND time_start>=i_startdate AND time_end<i_enddate AND customer_invoice_id IS NOT NULL;
                IF FOUND THEN
                        RAISE EXCEPTION 'billing.invoice_generate: some customer invoices already found for this interval';
                END IF;
                execute format('UPDATE cdr.cdr SET customer_invoice_id=%L
                    WHERE customer_acc_id =%L AND time_start>=%L AND time_end<%L AND customer_invoice_id IS NULL', v_id, i_account_id, i_startdate, i_enddate);

                /* we need rewrite this ot dynamic SQL to use partiotioning */
                execute format ('insert into billing.invoice_destinations(
                    dst_prefix,country_id,network_id,rate,calls_count,calls_duration,amount,invoice_id,first_call_at,last_call_at)
                    select  destination_prefix,
                            dst_country_id,
                            dst_network_id,
                            destination_next_rate,
                            count(nullif(is_last_cdr,false)),
                            sum(duration),
                            sum(customer_price),
                            %L,
                            min(time_start),
                            max(time_start)
                    from cdr.cdr
                    where customer_acc_id =%L AND time_start>=%L AND time_end<%L AND customer_invoice_id =%L
                    group by destination_prefix, dst_country_id, dst_network_id, destination_next_rate',v_id, i_account_id, i_startdate, i_enddate, v_id);

                SELECT INTO v_count,v_amount,v_min_date,v_max_date
                    coalesce(sum(calls_count),0),
                    COALESCE(sum(amount),0),
                    min(first_call_at),
                    max(last_call_at)
                from billing.invoice_destinations
                where invoice_id =v_id;


                UPDATE billing.invoices SET amount=v_amount,calls_count=v_count,first_call_date=v_min_date,last_call_date=v_max_date WHERE id=v_id;
        END IF;
RETURN v_id;
END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;

-- Function: stats.update_rt_stats(cdr)

-- DROP FUNCTION stats.update_rt_stats(cdr);

CREATE OR REPLACE FUNCTION stats.update_rt_stats(i_cdr cdr.cdr)
  RETURNS void AS
  $BODY$
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

    insert into stats.termination_quality_stats(dialpeer_id,gateway_id,time_start,success,duration)
        values(i_cdr.dialpeer_id, i_cdr.term_gw_id, i_cdr.time_start, i_cdr.success, i_cdr.duration);

    RETURN ;
END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 10;

-- Function: switch.writecdr(boolean, integer, integer, integer, boolean, integer, character varying, integer, character varying, integer, character varying, integer, character varying, integer, double precision, double precision, double precision, double precision, double precision, double precision, boolean, integer, character varying, integer, integer, character varying, integer, character varying, character varying, character varying, character varying, character varying, integer, json, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, integer, integer, integer, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, inet, integer, integer, integer, character varying, character varying, integer, character varying, smallint)

-- DROP FUNCTION switch.writecdr(boolean, integer, integer, integer, boolean, integer, character varying, integer, character varying, integer, character varying, integer, character varying, integer, double precision, double precision, double precision, double precision, double precision, double precision, boolean, integer, character varying, integer, integer, character varying, integer, character varying, character varying, character varying, character varying, character varying, integer, json, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, integer, integer, integer, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, inet, integer, integer, integer, character varying, character varying, integer, character varying, smallint);

CREATE OR REPLACE FUNCTION switch.writecdr(
  i_is_master boolean,
  i_node_id integer,
  i_pop_id integer,
  i_routing_attempt integer,
  i_is_last_cdr boolean,
  i_time_limit integer,
  i_lega_local_ip character varying,
  i_lega_local_port integer,
  i_lega_remote_ip character varying,
  i_lega_remote_port integer,
  i_legb_local_ip character varying,
  i_legb_local_port integer,
  i_legb_remote_ip character varying,
  i_legb_remote_port integer,
  i_time_start double precision,
  i_leg_b_time_start double precision,
  i_time_connect double precision,
  i_time_end double precision,
  i_time_1xx double precision,
  i_time_18x double precision,
  i_early_media_present boolean,
  i_legb_disconnect_code integer,
  i_legb_disconnect_reason character varying,
  i_disconnect_initiator integer,
  i_internal_disconnect_code integer,
  i_internal_disconnect_reason character varying,
  i_lega_disconnect_code integer,
  i_lega_disconnect_reason character varying,
  i_orig_call_id character varying,
  i_term_call_id character varying,
  i_local_tag character varying,
  i_msg_logger_path character varying,
  i_dump_level_id integer,
  i_rtp_stats_data json,
  i_global_tag character varying,
  i_customer_id character varying,
  i_vendor_id character varying,
  i_customer_acc_id character varying,
  i_vendor_acc_id character varying,
  i_customer_auth_id character varying,
  i_destination_id character varying,
  i_destination_prefix character varying,
  i_dialpeer_id character varying,
  i_dialpeer_prefix character varying,
  i_orig_gw_id character varying,
  i_term_gw_id character varying,
  i_routing_group_id character varying,
  i_rateplan_id character varying,
  i_destination_initial_rate character varying,
  i_destination_next_rate character varying,
  i_destination_initial_interval integer,
  i_destination_next_interval integer,
  i_destination_rate_policy_id integer,
  i_dialpeer_initial_interval integer,
  i_dialpeer_next_interval integer,
  i_dialpeer_next_rate character varying,
  i_destination_fee character varying,
  i_dialpeer_initial_rate character varying,
  i_dialpeer_fee character varying,
  i_dst_prefix_in character varying,
  i_dst_prefix_out character varying,
  i_src_prefix_in character varying,
  i_src_prefix_out character varying,
  i_src_name_in character varying,
  i_src_name_out character varying,
  i_diversion_in character varying,
  i_diversion_out character varying,
  i_auth_orig_ip inet,
  i_auth_orig_port integer,
  i_dst_country_id integer,
  i_dst_network_id integer,
  i_dst_prefix_routing character varying,
  i_src_prefix_routing character varying,
  i_routing_plan_id integer,
  i_lrn character varying,
  i_lnp_database_id smallint)
  RETURNS integer AS
  $BODY$
DECLARE
v_cdr cdr.cdr%rowtype;
v_billing_event billing.cdr_v2;

v_rtp_stats_data switch.rtp_stats_data_ty;

v_nozerolen boolean;
BEGIN
-- feel cdr fields;

v_cdr.pop_id=i_pop_id;
v_cdr.node_id=i_node_id;

v_cdr.src_name_in:=i_src_name_in;
v_cdr.src_name_out:=i_src_name_out;

v_cdr.diversion_in:=i_diversion_in;
v_cdr.diversion_out:=i_diversion_out;

v_cdr.customer_id:=i_customer_id;
v_cdr.vendor_id:=i_vendor_id;
v_cdr.customer_acc_id:=i_customer_acc_id;
v_cdr.vendor_acc_id:=i_vendor_acc_id;
v_cdr.customer_auth_id:=i_customer_auth_id;

v_cdr.destination_id:=i_destination_id;
v_cdr.destination_prefix:=i_destination_prefix;
v_cdr.dialpeer_id:=i_dialpeer_id;
v_cdr.dialpeer_prefix:=i_dialpeer_prefix;

v_cdr.orig_gw_id:=i_orig_gw_id;
v_cdr.term_gw_id:=i_term_gw_id;
v_cdr.routing_group_id:=i_routing_group_id;
v_cdr.rateplan_id:=i_rateplan_id;

v_cdr.routing_attempt=i_routing_attempt;
v_cdr.is_last_cdr=i_is_last_cdr;

v_cdr.destination_initial_rate:=i_destination_initial_rate::numeric;
v_cdr.destination_next_rate:=i_destination_next_rate::numeric;
v_cdr.destination_initial_interval:=i_destination_initial_interval;
v_cdr.destination_next_interval:=i_destination_next_interval;
v_cdr.destination_fee:=i_destination_fee;
v_cdr.destination_rate_policy_id:=i_destination_rate_policy_id;

v_cdr.dialpeer_initial_rate:=i_dialpeer_initial_rate::numeric;
v_cdr.dialpeer_next_rate:=i_dialpeer_next_rate::numeric;
v_cdr.dialpeer_initial_interval:=i_dialpeer_initial_interval;
v_cdr.dialpeer_next_interval:=i_dialpeer_next_interval;
v_cdr.dialpeer_fee:=i_dialpeer_fee;

v_cdr.time_limit:=i_time_limit;
/* sockets addresses */
v_cdr.sign_orig_ip:=i_legA_remote_ip;
v_cdr.sign_orig_port=i_legA_remote_port;
v_cdr.sign_orig_local_ip:=i_legA_local_ip;
v_cdr.sign_orig_local_port=i_legA_local_port;
v_cdr.sign_term_ip:=i_legB_remote_ip;
v_cdr.sign_term_port:=NULLIF(i_legB_remote_port,0);
v_cdr.sign_term_local_ip:=i_legB_local_ip;
v_cdr.sign_term_local_port:=NULLIF(i_legB_local_port,0);

v_cdr.local_tag=i_local_tag;

v_cdr.time_start:=to_timestamp(i_time_start);

if i_time_connect is not null then
    v_cdr.time_connect:=to_timestamp(i_time_connect);
    v_cdr.duration:=switch.round(i_time_end-i_time_connect); -- rounding
    v_nozerolen:=true;
    v_cdr.success=true;
else
    v_cdr.time_connect:=NULL;
    v_cdr.duration:=0;
    v_nozerolen:=false;
    v_cdr.success=false;
end if;
v_cdr.routing_delay=(i_leg_b_time_start-i_time_start)::real;
v_cdr.pdd=(coalesce(i_time_18x,i_time_connect)-i_time_start)::real;
v_cdr.rtt=(coalesce(i_time_1xx,i_time_18x,i_time_connect)-i_leg_b_time_start)::real;
v_cdr.early_media_present=i_early_media_present;

v_cdr.time_end:=to_timestamp(i_time_end);

-- DC processing
v_cdr.legb_disconnect_code:=i_legb_disconnect_code;
v_cdr.legb_disconnect_reason:=i_legb_disconnect_reason;
v_cdr.disconnect_initiator_id:=i_disconnect_initiator;
v_cdr.internal_disconnect_code:=i_internal_disconnect_code;
v_cdr.internal_disconnect_reason:=i_internal_disconnect_reason;
v_cdr.lega_disconnect_code:=i_lega_disconnect_code;
v_cdr.lega_disconnect_reason:=i_lega_disconnect_reason;

v_cdr.src_prefix_in:=i_src_prefix_in;
v_cdr.src_prefix_out:=i_src_prefix_out;
v_cdr.dst_prefix_in:=i_dst_prefix_in;
v_cdr.dst_prefix_out:=i_dst_prefix_out;

v_cdr.orig_call_id=i_orig_call_id;
v_cdr.term_call_id=i_term_call_id;
v_cdr.dump_file:=i_msg_logger_path;
v_cdr.dump_level_id:=i_dump_level_id;

v_cdr.auth_orig_ip:=i_auth_orig_ip;
v_cdr.auth_orig_port:=i_auth_orig_port;


v_rtp_stats_data:=json_populate_record(null::switch.rtp_stats_data_ty, i_rtp_stats_data);

v_cdr.lega_rx_payloads:=v_rtp_stats_data.lega_rx_payloads;
v_cdr.lega_tx_payloads:=v_rtp_stats_data.lega_tx_payloads;
v_cdr.legb_rx_payloads:=v_rtp_stats_data.legb_rx_payloads;
v_cdr.legb_tx_payloads:=v_rtp_stats_data.legb_tx_payloads;

v_cdr.lega_rx_bytes:=v_rtp_stats_data.lega_rx_bytes;
v_cdr.lega_tx_bytes:=v_rtp_stats_data.lega_tx_bytes;
v_cdr.legb_rx_bytes:=v_rtp_stats_data.legb_rx_bytes;
v_cdr.legb_tx_bytes:=v_rtp_stats_data.legb_tx_bytes;

v_cdr.lega_rx_decode_errs:=v_rtp_stats_data.lega_rx_decode_errs;
v_cdr.lega_rx_no_buf_errs:=v_rtp_stats_data.lega_rx_no_buf_errs;
v_cdr.lega_rx_parse_errs:=v_rtp_stats_data.lega_rx_parse_errs;
v_cdr.legb_rx_decode_errs:=v_rtp_stats_data.legb_rx_decode_errs;
v_cdr.legb_rx_no_buf_errs:=v_rtp_stats_data.legb_rx_no_buf_errs;
v_cdr.legb_rx_parse_errs:=v_rtp_stats_data.legb_rx_parse_errs;

v_cdr.global_tag=i_global_tag;

v_cdr.dst_country_id=i_dst_country_id;
v_cdr.dst_network_id=i_dst_network_id;
v_cdr.dst_prefix_routing=i_dst_prefix_routing;
v_cdr.src_prefix_routing=i_src_prefix_routing;
v_cdr.routing_plan_id=i_routing_plan_id;
v_cdr.lrn=i_lrn;
v_cdr.lnp_database_id=i_lnp_database_id;


    v_cdr.id:=nextval('cdr.cdr_id_seq'::regclass);
    v_cdr:=billing.bill_cdr(v_cdr);

    perform stats.update_rt_stats(v_cdr);


    v_billing_event.id=v_cdr.id;
    v_billing_event.customer_id=v_cdr.customer_id;
    v_billing_event.vendor_id=v_cdr.vendor_id;
    v_billing_event.customer_acc_id=v_cdr.customer_acc_id;
    v_billing_event.vendor_acc_id=v_cdr.vendor_acc_id;
    v_billing_event.customer_auth_id=v_cdr.customer_auth_id;
    v_billing_event.destination_id=v_cdr.destination_id;
    v_billing_event.dialpeer_id=v_cdr.dialpeer_id;
    v_billing_event.orig_gw_id=v_cdr.orig_gw_id;
    v_billing_event.term_gw_id=v_cdr.term_gw_id;
    v_billing_event.routing_group_id=v_cdr.routing_group_id;
    v_billing_event.rateplan_id=v_cdr.rateplan_id;
    v_billing_event.destination_next_rate=v_cdr.destination_next_rate;
    v_billing_event.destination_fee=v_cdr.destination_fee;
    v_billing_event.dialpeer_next_rate=v_cdr.dialpeer_next_rate;
    v_billing_event.dialpeer_fee=v_cdr.dialpeer_fee;
    v_billing_event.internal_disconnect_code=v_cdr.internal_disconnect_code;
    v_billing_event.internal_disconnect_reason=v_cdr.internal_disconnect_reason;
    v_billing_event.disconnect_initiator_id=v_cdr.disconnect_initiator_id;
    v_billing_event.customer_price=v_cdr.customer_price;
    v_billing_event.vendor_price=v_cdr.vendor_price;
    v_billing_event.duration=v_cdr.duration;
    v_billing_event.success=v_cdr.success;
    v_billing_event.profit=v_cdr.profit;
    v_billing_event.time_start=v_cdr.time_start;
    v_billing_event.time_connect=v_cdr.time_connect;
    v_billing_event.time_end=v_cdr.time_end;
    v_billing_event.lega_disconnect_code=v_cdr.lega_disconnect_code;
    v_billing_event.lega_disconnect_reason=v_cdr.lega_disconnect_reason;
    v_billing_event.legb_disconnect_code=v_cdr.legb_disconnect_code;
    v_billing_event.legb_disconnect_reason=v_cdr.legb_disconnect_reason;

        -- generate event to routing engine
    perform event.billing_insert_event('cdr_full',v_billing_event);
    INSERT INTO cdr.cdr VALUES( v_cdr.*);
    RETURN 0;
END;
$BODY$
LANGUAGE plpgsql VOLATILE SECURITY DEFINER
COST 10;


commit;