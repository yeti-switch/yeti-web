begin;

insert into sys.version(number,comment) values(2,'New billing event format');

select pgq.unregister_consumer('cdr_billing','cdr_billing');
select pgq.drop_queue('cdr_billing');
select pgq.create_queue('cdr_billing');
select pgq.register_consumer('cdr_billing','cdr_billing');


CREATE TYPE billing.cdr_v2 AS
   (id bigint,
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
    internal_disconnect_code integer,
    internal_disconnect_reason character varying,
    disconnect_initiator_id integer,
    customer_price numeric,
    vendor_price numeric,
    duration integer,
    success boolean,
    profit numeric,
    time_start timestamp without time zone,
    time_connect timestamp without time zone,
    time_end timestamp without time zone,
    lega_disconnect_code integer,
    lega_disconnect_reason character varying,
    legb_disconnect_code integer,
    legb_disconnect_reason character varying
);


CREATE OR REPLACE FUNCTION switch.writecdr(i_is_master boolean, i_node_id integer, i_pop_id integer, i_routing_attempt integer, i_is_last_cdr boolean, i_time_limit integer, i_lega_local_ip character varying, i_lega_local_port integer, i_lega_remote_ip character varying, i_lega_remote_port integer, i_legb_local_ip character varying, i_legb_local_port integer, i_legb_remote_ip character varying, i_legb_remote_port integer, i_time_start bigint, i_time_connect bigint, i_time_end bigint, i_legb_disconnect_code integer, i_legb_disconnect_reason character varying, i_disconnect_initiator integer, i_internal_disconnect_code integer, i_internal_disconnect_reason character varying, i_lega_disconnect_code integer, i_lega_disconnect_reason character varying, i_orig_call_id character varying, i_term_call_id character varying, i_local_tag character varying, i_msg_logger_path character varying, i_dump_level_id integer, i_lega_rx_payloads character varying, i_lega_tx_payloads character varying, i_legb_rx_payloads character varying, i_legb_tx_payloads character varying, i_lega_rx_bytes integer, i_lega_tx_bytes integer, i_legb_rx_bytes integer, i_legb_tx_bytes integer, i_global_tag character varying, i_customer_id character varying, i_vendor_id character varying, i_customer_acc_id character varying, i_vendor_acc_id character varying, i_customer_auth_id character varying, i_destination_id character varying, i_dialpeer_id character varying, i_orig_gw_id character varying, i_term_gw_id character varying, i_routing_group_id character varying, i_rateplan_id character varying, i_destination_initial_rate character varying, i_destination_next_rate character varying, i_destination_initial_interval integer, i_destination_next_interval integer, i_destination_rate_policy_id integer, i_dialpeer_initial_interval integer, i_dialpeer_next_interval integer, i_dialpeer_next_rate character varying, i_destination_fee character varying, i_dialpeer_initial_rate character varying, i_dialpeer_fee character varying, i_dst_prefix_in character varying, i_dst_prefix_out character varying, i_src_prefix_in character varying, i_src_prefix_out character varying, i_src_name_in character varying, i_src_name_out character varying, i_diversion_in character varying, i_diversion_out character varying, i_auth_orig_ip inet, i_auth_orig_port integer)
  RETURNS integer AS
$BODY$
DECLARE
v_cdr cdr.cdr%rowtype;
v_billing_event billing.cdr_v2;
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

v_cdr.lega_rx_payloads:=i_legA_rx_payloads;
v_cdr.lega_tx_payloads:=i_legA_tx_payloads;
v_cdr.legb_rx_payloads:=i_legB_rx_payloads;
v_cdr.legb_tx_payloads:=i_legB_tx_payloads;

v_cdr.lega_rx_bytes:=i_legA_rx_bytes;
v_cdr.lega_tx_bytes:=i_legA_tx_bytes;
v_cdr.legb_rx_bytes:=i_legB_rx_bytes;
v_cdr.legb_tx_bytes:=i_legB_tx_bytes;
v_cdr.global_tag=i_global_tag;


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

commit;
