begin;
insert into sys.version(number,comment) values(8,'Invoices fix');

CREATE TABLE billing.invoices
(
  id serial primary key,
  account_id integer NOT NULL,
  start_date timestamp without time zone NOT NULL,
  end_date timestamp without time zone NOT NULL,
  amount numeric NOT NULL,
  vendor_invoice boolean NOT NULL DEFAULT false,
  cdrs bigint NOT NULL,
  first_cdr_date timestamp without time zone,
  last_cdr_date timestamp without time zone,
  contractor_id integer
);


CREATE OR REPLACE FUNCTION billing.invoice_generate(i_contractor_id integer, i_account_id integer, i_vendor_flag boolean, i_startdate timestamp without time zone, i_enddate timestamp without time zone)
  RETURNS integer AS
$BODY$
DECLARE
v_id integer;
v_amount numeric;
v_count bigint;
v_min_date timestamp;
v_max_date timestamp;
BEGIN
        BEGIN
                INSERT into billing.invoices(contractor_id,account_id,start_date,end_date,amount,vendor_invoice,cdrs)
                        VALUES(i_contractor_id,i_account_id,i_startdate,i_enddate,0,i_vendor_flag,0) RETURNING id INTO v_id;
        EXCEPTION
                WHEN foreign_key_violation THEN
                        RAISE EXCEPTION 'billing.invoice_generate: account not found in this moment';
        END;

        if i_vendor_flag THEN
                PERFORM * FROM cdr.cdr WHERE vendor_acc_id =i_account_id AND time_start>=i_startdate AND time_end<i_enddate AND vendor_invoice_id IS NOT NULL;
                IF FOUND THEN
                        RAISE EXCEPTION 'billing.invoice_generate: some vendor invoices already found for this interval';
                END IF;
                UPDATE cdr.cdr SET vendor_invoice_id=v_id WHERE vendor_acc_id =i_account_id AND time_start>=i_startdate AND time_end<i_enddate AND vendor_invoice_id IS NULL;
                SELECT INTO v_count,v_amount,v_min_date,v_max_date
                        count(*),
                        COALESCE(sum(vendor_price),0),
                        min(time_start),
                        max(time_start)
                        from cdr.cdr 
                        WHERE vendor_acc_id =i_account_id AND time_start>=i_startdate AND time_end<i_enddate AND vendor_invoice_id =v_id;
                        RAISE NOTICE 'wer % - %',v_count,v_amount;
                UPDATE billing.invoices SET amount=v_amount,cdrs=v_count,first_cdr_date=v_min_date,last_cdr_date=v_max_date WHERE id=v_id;
        ELSE
                PERFORM * FROM cdr.cdr WHERE customer_acc_id =i_account_id AND time_start>=i_startdate AND time_end<i_enddate AND customer_invoice_id IS NOT NULL;
                IF FOUND THEN
                        RAISE EXCEPTION 'billing.invoice_generate: some customer invoices already found for this interval';
                END IF;
                UPDATE cdr.cdr SET customer_invoice_id=v_id WHERE customer_acc_id =i_account_id AND time_start>=i_startdate AND time_end<i_enddate AND customer_invoice_id IS NULL;
                SELECT INTO v_count,v_amount,v_min_date,v_max_date
                        count(*),
                        COALESCE(sum(customer_price),0),
                        min(time_start),
                        max(time_start)
                         from cdr.cdr
                        WHERE customer_acc_id =i_account_id AND time_start>=i_startdate AND time_end<i_enddate AND customer_invoice_id =v_id;
                UPDATE billing.invoices SET amount=v_amount,cdrs=v_count,first_cdr_date=v_min_date,last_cdr_date=v_max_date WHERE id=v_id;
        END IF;
RETURN v_id;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;


CREATE OR REPLACE FUNCTION billing.invoice_remove(i_invoice_id integer)
  RETURNS void AS
$BODY$
DECLARE
v_vendor_flag boolean;
BEGIN
        SELECT into v_vendor_flag vendor_invoice from billing.invoices WHERE id=i_invoice_id;
        IF NOT FOUND THEN
               --RAISE EXCEPTION 'Already removed';
               RETURN;
        END IF;

        IF v_vendor_flag THEN
                UPdate cdr.cdr set vendor_invoice_id = NULL where vendor_invoice_id=i_invoice_id;
        ELSE
                UPdate cdr.cdr set customer_invoice_id = NULL where customer_invoice_id=i_invoice_id;
        END IF;

        DELETE FROM billing.invoices where id=i_invoice_id;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

ALTER TABLE cdr.cdr add src_prefix_routing varchar, add dst_prefix_routing varchar;
--update cdr.cdr set dst_prefix_routing =dst_prefix_in,src_prefix_routing =src_prefix_in where dst_prefix_routing is null;
alter table cdr.cdr add routing_plan_id integer;
--update cdr.cdr set routing_plan_id=routing_group_id where routing_plan_id is null;
alter table cdr.cdr drop column customer_billed, drop column vendor_billed;
create table cdr.cdr_archive as select * from cdr.cdr where 1=0;




CREATE OR REPLACE FUNCTION sys.cdrtable_tgr_reload()
  RETURNS void AS
$BODY$
DECLARE
v_tbname varchar;
v_sql1 varchar:='CREATE OR REPLACE FUNCTION cdr.cdr_i_tgf() RETURNS trigger AS $trg$ 
BEGIN  [MEAT]  
RETURN NULL; 
END; $trg$ LANGUAGE plpgsql VOLATILE COST 100';
--v_sql2 varchar:='ALTER FUNCTION cdrs.cdrs_i_tgf() OWNER TO accadmin;';
v_tb_row record;
v_meat varchar;
v_prfx varchar;
v_counter integer;
BEGIN
        v_meat:='';
        v_counter:='1';
        PERFORM * FROM sys.cdr_tables WHERE active;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'no tables for write data';
        end IF;
        FOR v_tb_row IN SELECT * FROM sys.cdr_tables WHERE active ORDER BY date_start LOOP
                IF v_counter=1 THEN
                        v_prfx='IF ';
                ELSE 
                        v_prfx='ELSIF ';
                END IF;
                v_meat:=v_meat||v_prfx||'( NEW.time_start >= DATE '''||v_tb_row.date_start||''' AND NEW.time_start < DATE '''||v_tb_row.date_stop||''' ) THEN INSERT INTO '||v_tb_row.name||' VALUES (NEW.*);'|| E'\n';
                v_counter:=v_counter+1;
        END LOOP;
        v_meat:=v_meat||' ELSE '|| E'\n'||' RAISE EXCEPTION ''cdr.cdr_i_tg: time_start out of range.''; '||E'\n'||' END IF;';
        v_sql1:=REPLACE(v_sql1,'[MEAT]',v_meat);
        set standard_conforming_strings=on;
        EXECUTE v_sql1;
      --  EXECUTE v_sql2;
        RAISE NOTICE 'sys.cdrtable_tgr_reload: CDR trigger reloaded';
       -- RETURN 'OK';
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

DROP FUNCTION sys.cdr_drop_table(character varying);


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
  i_time_start bigint,
  i_time_connect bigint,
  i_time_end bigint,
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
  i_dialpeer_id character varying,
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
  i_routing_plan_id integer
)
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
v_cdr.dialpeer_id:=i_dialpeer_id;
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
IF i_time_connect!=0::bigint THEN -- BUG in WEB interface
    v_cdr.time_connect:=to_timestamp(i_time_connect);
    v_cdr.duration:=i_time_end-i_time_connect;
    v_nozerolen:=true;
    v_cdr.success=true;
ELSE
    v_cdr.time_connect:=NULL;
    v_cdr.duration:=0;
    v_nozerolen:=false;
    v_cdr.success=false;
END IF;
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


    v_cdr.id:=nextval('cdr.cdr_id_seq'::regclass);
    v_cdr:=billing.bill_cdr(v_cdr);


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


CREATE OR REPLACE FUNCTION billing.bill_cdr(i_cdr cdr.cdr)
  RETURNS cdr.cdr AS
  $BODY$
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
            0);
         i_cdr.customer_price=_v.amount;

         _v=billing.interval_billing(
            i_cdr.duration,
            i_cdr.dialpeer_fee,
            i_cdr.dialpeer_initial_rate,
            i_cdr.dialpeer_next_rate,
            i_cdr.dialpeer_initial_interval,
            i_cdr.dialpeer_next_interval,
            0);
         i_cdr.vendor_price=_v.amount;
         i_cdr.profit=i_cdr.customer_price-i_cdr.vendor_price;
    else
        i_cdr.customer_price=0;
        i_cdr.vendor_price=0;
        i_cdr.profit=0;
    end if;
    RETURN i_cdr;
END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 10;

alter table sys.cdr_tables add active boolean not null DEFAULT  true;

commit;
