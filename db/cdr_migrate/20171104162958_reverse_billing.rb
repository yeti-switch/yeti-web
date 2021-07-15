class ReverseBilling < ActiveRecord::Migration
  def up
    execute %q{

      alter type billing.cdr_v2
        add attribute destination_reverse_billing boolean,
        add attribute dialpeer_reverse_billing boolean;

      alter table cdr.cdr
        add destination_reverse_billing boolean,
        add dialpeer_reverse_billing boolean,
        add is_redirected boolean,
        add customer_account_check_balance boolean;

      alter table cdr.cdr_archive
        add destination_reverse_billing boolean,
        add dialpeer_reverse_billing boolean,
        add is_redirected boolean,
        add customer_account_check_balance boolean;

-- Function: switch.writecdr(boolean, integer, integer, integer, boolean, smallint, character varying, integer, character varying, integer, smallint, character varying, integer, character varying, integer, json, boolean, integer, character varying, integer, integer, character varying, integer, character varying, character varying, character varying, character varying, character varying, integer, boolean, json, character varying, character varying, json, smallint, bigint, json, json, boolean, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, integer, integer, integer, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, smallint, inet, integer, integer, integer, character varying, character varying, integer, character varying, smallint, character varying, character varying, character varying, integer, integer, smallint, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, boolean, boolean, boolean)

-- DROP FUNCTION switch.writecdr(boolean, integer, integer, integer, boolean, smallint, character varying, integer, character varying, integer, smallint, character varying, integer, character varying, integer, json, boolean, integer, character varying, integer, integer, character varying, integer, character varying, character varying, character varying, character varying, character varying, integer, boolean, json, character varying, character varying, json, smallint, bigint, json, json, boolean, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, integer, integer, integer, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, smallint, inet, integer, integer, integer, character varying, character varying, integer, character varying, smallint, character varying, character varying, character varying, integer, integer, smallint, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, boolean, boolean, boolean);

CREATE OR REPLACE FUNCTION switch.writecdr(
    i_is_master boolean,
    i_node_id integer,
    i_pop_id integer,
    i_routing_attempt integer,
    i_is_last_cdr boolean,
    i_lega_transport_protocol_id smallint,
    i_lega_local_ip character varying,
    i_lega_local_port integer,
    i_lega_remote_ip character varying,
    i_lega_remote_port integer,
    i_legb_transport_protocol_id smallint,
    i_legb_local_ip character varying,
    i_legb_local_port integer,
    i_legb_remote_ip character varying,
    i_legb_remote_port integer,
    i_time_data json,
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
    i_audio_recorded boolean,
    i_rtp_stats_data json,
    i_global_tag character varying,
    i_resources character varying,
    i_active_resources json,
    i_failed_resource_type_id smallint,
    i_failed_resource_id bigint,
    i_dtmf_events json,
    i_versions json,
    i_is_redirected boolean,
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
    i_auth_orig_protocol_id smallint,
    i_auth_orig_ip inet,
    i_auth_orig_port integer,
    i_dst_country_id integer,
    i_dst_network_id integer,
    i_dst_prefix_routing character varying,
    i_src_prefix_routing character varying,
    i_routing_plan_id integer,
    i_lrn character varying,
    i_lnp_database_id smallint,
    i_from_domain character varying,
    i_to_domain character varying,
    i_ruri_domain character varying,
    i_src_area_id integer,
    i_dst_area_id integer,
    i_routing_tag_id smallint,
    i_pai_in character varying,
    i_ppi_in character varying,
    i_privacy_in character varying,
    i_rpid_in character varying,
    i_rpid_privacy_in character varying,
    i_pai_out character varying,
    i_ppi_out character varying,
    i_privacy_out character varying,
    i_rpid_out character varying,
    i_rpid_privacy_out character varying,
    i_customer_acc_check_balance boolean,
    i_destination_reverse_billing boolean,
    i_dialpeer_reverse_billing boolean)
  RETURNS integer AS
$BODY$
DECLARE
  v_cdr cdr.cdr%rowtype;
  v_billing_event billing.cdr_v2;

  v_rtp_stats_data switch.rtp_stats_data_ty;
  v_time_data switch.time_data_ty;
  v_version_data switch.versions_ty;


  v_nozerolen boolean;
BEGIN
  --  raise warning 'type: % id: %', i_failed_resource_type_id, i_failed_resource_id;
  --  RAISE warning 'DTMF: %', i_dtmf_events;

  v_time_data:=json_populate_record(null::switch.time_data_ty, i_time_data);
  v_version_data:=json_populate_record(null::switch.versions_ty, i_versions);

  v_cdr.core_version=v_version_data.core;
  v_cdr.yeti_version=v_version_data.yeti;
  v_cdr.lega_user_agent=v_version_data.aleg;
  v_cdr.legb_user_agent=v_version_data.bleg;

  v_cdr.pop_id=i_pop_id;
  v_cdr.node_id=i_node_id;

  v_cdr.src_name_in:=i_src_name_in;
  v_cdr.src_name_out:=i_src_name_out;

  v_cdr.diversion_in:=i_diversion_in;
  v_cdr.diversion_out:=i_diversion_out;

  v_cdr.customer_id:=i_customer_id;
  v_cdr.customer_account_check_balance=i_customer_acc_check_balance;

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
  v_cdr.destination_reverse_billing=i_destination_reverse_billing;

  v_cdr.dialpeer_initial_rate:=i_dialpeer_initial_rate::numeric;
  v_cdr.dialpeer_next_rate:=i_dialpeer_next_rate::numeric;
  v_cdr.dialpeer_initial_interval:=i_dialpeer_initial_interval;
  v_cdr.dialpeer_next_interval:=i_dialpeer_next_interval;
  v_cdr.dialpeer_fee:=i_dialpeer_fee;
  v_cdr.dialpeer_reverse_billing=i_dialpeer_reverse_billing;

  /* sockets addresses */
  v_cdr.sign_orig_transport_protocol_id=i_lega_transport_protocol_id;
  v_cdr.sign_orig_ip:=i_legA_remote_ip;
  v_cdr.sign_orig_port=i_legA_remote_port;
  v_cdr.sign_orig_local_ip:=i_legA_local_ip;
  v_cdr.sign_orig_local_port=i_legA_local_port;

  v_cdr.sign_term_transport_protocol_id=i_legb_transport_protocol_id;
  v_cdr.sign_term_ip:=i_legB_remote_ip;
  v_cdr.sign_term_port:=NULLIF(i_legB_remote_port,0);
  v_cdr.sign_term_local_ip:=i_legB_local_ip;
  v_cdr.sign_term_local_port:=NULLIF(i_legB_local_port,0);

  v_cdr.local_tag=i_local_tag;

  v_cdr.is_redirected=i_is_redirected;

  /* Call time data */
  v_cdr.time_start:=to_timestamp(v_time_data.time_start);
  v_cdr.time_limit:=v_time_data.time_limit;

  if v_time_data.time_connect is not null then
    v_cdr.time_connect:=to_timestamp(v_time_data.time_connect);
    v_cdr.duration:=switch.round(v_time_data.time_end-v_time_data.time_connect); -- rounding
    v_nozerolen:=true;
    v_cdr.success=true;
  else
    v_cdr.time_connect:=NULL;
    v_cdr.duration:=0;
    v_nozerolen:=false;
    v_cdr.success=false;
  end if;
  v_cdr.routing_delay=(v_time_data.leg_b_time-v_time_data.time_start)::real;
  v_cdr.pdd=(coalesce(v_time_data.time_18x,v_time_data.time_connect)-v_time_data.time_start)::real;
  v_cdr.rtt=(coalesce(v_time_data.time_1xx,v_time_data.time_18x,v_time_data.time_connect)-v_time_data.leg_b_time)::real;
  v_cdr.early_media_present=i_early_media_present;

  v_cdr.time_end:=to_timestamp(v_time_data.time_end);

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

  /* removed */
  --v_cdr.dump_file:=i_msg_logger_path;

  v_cdr.dump_level_id:=i_dump_level_id;
  v_cdr.audio_recorded:=i_audio_recorded;

  v_cdr.auth_orig_transport_protocol_id=i_auth_orig_protocol_id;
  v_cdr.auth_orig_ip:=i_auth_orig_ip;
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

  v_cdr.ruri_domain=i_ruri_domain;
  v_cdr.to_domain=i_to_domain;
  v_cdr.from_domain=i_from_domain;

  v_cdr.src_area_id=i_src_area_id;
  v_cdr.dst_area_id=i_dst_area_id;
  v_cdr.routing_tag_id=i_routing_tag_id;


  v_cdr.id:=nextval('cdr.cdr_id_seq'::regclass);
  v_cdr.uuid:=public.uuid_generate_v1();

  v_cdr.pai_in=i_pai_in;
  v_cdr.ppi_in=i_ppi_in;
  v_cdr.privacy_in=i_privacy_in;
  v_cdr.rpid_in=i_rpid_in;
  v_cdr.rpid_privacy_in=i_rpid_privacy_in;
  v_cdr.pai_out=i_pai_out;
  v_cdr.ppi_out=i_ppi_out;
  v_cdr.privacy_out=i_privacy_out;
  v_cdr.rpid_out=i_rpid_out;
  v_cdr.rpid_privacy_out=i_rpid_privacy_out;


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
  v_billing_event.destination_initial_interval=v_cdr.destination_initial_interval;
  v_billing_event.destination_next_interval=v_cdr.destination_next_interval;
  v_billing_event.destination_initial_rate=v_cdr.destination_initial_rate;
  v_billing_event.destination_reverse_billing=v_cdr.destination_reverse_billing;

  v_billing_event.dialpeer_next_rate=v_cdr.dialpeer_next_rate;
  v_billing_event.dialpeer_fee=v_cdr.dialpeer_fee;
  v_billing_event.dialpeer_reverse_billing=v_cdr.dialpeer_reverse_billing;

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
  v_billing_event.src_prefix_in=v_cdr.src_prefix_in;
  v_billing_event.src_prefix_out=v_cdr.src_prefix_out;
  v_billing_event.dst_prefix_in=v_cdr.dst_prefix_in;
  v_billing_event.dst_prefix_out=v_cdr.dst_prefix_out;
  v_billing_event.orig_call_id=v_cdr.orig_call_id;
  v_billing_event.term_call_id=v_cdr.term_call_id;
  v_billing_event.local_tag=v_cdr.local_tag;
  v_billing_event.from_domain=v_cdr.from_domain;

  -- generate event to routing engine
  perform event.billing_insert_event('cdr_full',v_billing_event);
  INSERT INTO cdr.cdr VALUES( v_cdr.*);
  RETURN 0;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER
  COST 10;

    }
  end

  def down
    execute %q{

  DROP FUNCTION switch.writecdr(boolean, integer, integer, integer, boolean, smallint, character varying, integer, character varying, integer, smallint, character varying, integer, character varying, integer, json, boolean, integer, character varying, integer, integer, character varying, integer, character varying, character varying, character varying, character varying, character varying, integer, boolean, json, character varying, character varying, json, smallint, bigint, json, json, boolean, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, integer, integer, integer, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, smallint, inet, integer, integer, integer, character varying, character varying, integer, character varying, smallint, character varying, character varying, character varying, integer, integer, smallint, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, boolean, boolean, boolean);

    alter table cdr.cdr
        drop column destination_reverse_billing,
        drop column dialpeer_reverse_billing,
        drop column is_redirected,
        drop column customer_account_check_balance;

    alter table cdr.cdr_archive
        drop column destination_reverse_billing,
        drop column dialpeer_reverse_billing,
        drop column is_redirected,
        drop column customer_account_check_balance;

    alter type billing.cdr_v2
        drop attribute destination_reverse_billing,
        drop attribute dialpeer_reverse_billing;

    }
  end
end
