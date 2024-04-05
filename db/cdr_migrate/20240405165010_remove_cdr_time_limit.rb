class RemoveCdrTimeLimit < ActiveRecord::Migration[7.0]
  def up
    execute %q{

DROP FUNCTION IF EXISTS switch.writecdr(i_is_master boolean, i_node_id integer, i_pop_id integer, i_routing_attempt integer, i_is_last_cdr boolean, i_lega_transport_protocol_id smallint, i_lega_local_ip character varying, i_lega_local_port integer, i_lega_remote_ip character varying, i_lega_remote_port integer, i_legb_transport_protocol_id smallint, i_legb_local_ip character varying, i_legb_local_port integer, i_legb_remote_ip character varying, i_legb_remote_port integer, i_legb_ruri character varying, i_legb_outbound_proxy character varying, i_time_data json, i_early_media_present boolean, i_legb_disconnect_code integer, i_legb_disconnect_reason character varying, i_disconnect_initiator integer, i_internal_disconnect_code integer, i_internal_disconnect_reason character varying, i_lega_disconnect_code integer, i_lega_disconnect_reason character varying, i_orig_call_id character varying, i_term_call_id character varying, i_local_tag character varying, i_legb_local_tag character varying, i_msg_logger_path character varying, i_dump_level_id smallint, i_audio_recorded boolean, i_rtp_stats_data json, i_rtp_statistics json, i_global_tag character varying, i_resources character varying, i_active_resources json, i_failed_resource_type_id smallint, i_failed_resource_id bigint, i_dtmf_events json, i_versions json, i_is_redirected boolean, i_dynamic json);

DROP FUNCTION IF EXISTS switch.writecdr(i_is_master boolean, i_node_id integer, i_pop_id integer, i_routing_attempt integer, i_is_last_cdr boolean, i_lega_transport_protocol_id smallint, i_lega_local_ip character varying, i_lega_local_port integer, i_lega_remote_ip character varying, i_lega_remote_port integer, i_legb_transport_protocol_id smallint, i_legb_local_ip character varying, i_legb_local_port integer, i_legb_remote_ip character varying, i_legb_remote_port integer, i_legb_ruri character varying, i_legb_outbound_proxy character varying, i_time_data json, i_early_media_present boolean, i_legb_disconnect_code integer, i_legb_disconnect_reason character varying, i_disconnect_initiator integer, i_internal_disconnect_code integer, i_internal_disconnect_reason character varying, i_lega_disconnect_code integer, i_lega_disconnect_reason character varying, i_orig_call_id character varying, i_term_call_id character varying, i_local_tag character varying, i_legb_local_tag character varying, i_msg_logger_path character varying, i_dump_level_id smallint, i_audio_recorded boolean, i_rtp_stats_data json, i_rtp_statistics json, i_global_tag character varying, i_resources character varying, i_active_resources json, i_failed_resource_type_id smallint, i_failed_resource_id bigint, i_dtmf_events json, i_versions json, i_is_redirected boolean, i_dynamic json, i_lega_headers json);

CREATE or replace FUNCTION switch.writecdr(i_is_master boolean, i_node_id integer, i_pop_id integer, i_routing_attempt integer, i_is_last_cdr boolean, i_lega_transport_protocol_id smallint, i_lega_local_ip character varying, i_lega_local_port integer, i_lega_remote_ip character varying, i_lega_remote_port integer, i_legb_transport_protocol_id smallint, i_legb_local_ip character varying, i_legb_local_port integer, i_legb_remote_ip character varying, i_legb_remote_port integer, i_legb_ruri character varying, i_legb_outbound_proxy character varying, i_time_data json, i_early_media_present boolean, i_legb_disconnect_code integer, i_legb_disconnect_reason character varying, i_disconnect_initiator integer, i_internal_disconnect_code integer, i_internal_disconnect_reason character varying, i_lega_disconnect_code integer, i_lega_disconnect_reason character varying, i_orig_call_id character varying, i_term_call_id character varying, i_local_tag character varying, i_legb_local_tag character varying, i_msg_logger_path character varying, i_dump_level_id smallint, i_audio_recorded boolean, i_rtp_stats_data json, i_rtp_statistics json, i_global_tag character varying, i_resources character varying, i_active_resources json, i_failed_resource_type_id smallint, i_failed_resource_id bigint, i_dtmf_events json, i_versions json, i_is_redirected boolean, i_dynamic json, i_lega_headers json, i_legb_headers json, i_lega_identity json) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER COST 10
    AS $$
DECLARE
  v_cdr cdr.cdr%rowtype;

  v_time_data switch.time_data_ty;
  v_version_data switch.versions_ty;
  v_dynamic switch.dynamic_cdr_data_ty;

  v_nozerolen boolean;
  v_config sys.config%rowtype;

  v_rtp_rx_stream_data rtp_statistics.rx_streams%rowtype;
  v_rtp_tx_stream_data rtp_statistics.tx_streams%rowtype;

  v_lega_headers switch.lega_headers_ty;
  v_legb_headers switch.legb_headers_ty;
  v_lega_reason switch.reason_ty;
  v_legb_reason switch.reason_ty;
BEGIN
  --  raise warning 'type: % id: %', i_failed_resource_type_id, i_failed_resource_id;
  --  RAISE warning 'DTMF: %', i_dtmf_events;

  v_time_data:=json_populate_record(null::switch.time_data_ty, i_time_data);
  v_version_data:=json_populate_record(null::switch.versions_ty, i_versions);
  v_dynamic:=json_populate_record(null::switch.dynamic_cdr_data_ty, i_dynamic);

  v_lega_headers:=json_populate_record(null::switch.lega_headers_ty, i_lega_headers);
  v_legb_headers:=json_populate_record(null::switch.legb_headers_ty, i_legb_headers);

  v_cdr.p_charge_info_in = v_lega_headers.p_charge_info;

  v_lega_reason = v_lega_headers.reason;
  v_cdr.lega_q850_cause = v_lega_reason.q850_cause;
  v_cdr.lega_q850_text = v_lega_reason.q850_text;
  v_cdr.lega_q850_params = v_lega_reason.q850_params;

  v_legb_reason = v_legb_headers.reason;
  v_cdr.legb_q850_cause = v_legb_reason.q850_cause;
  v_cdr.legb_q850_text = v_legb_reason.q850_text;
  v_cdr.legb_q850_params = v_legb_reason.q850_params;

  v_cdr.lega_identity = i_lega_identity;
  v_cdr.lega_ss_status_id = v_dynamic.lega_ss_status_id;
  v_cdr.legb_ss_status_id = v_dynamic.legb_ss_status_id;

  v_cdr.metadata = v_dynamic.metadata::jsonb;

  v_cdr.core_version=v_version_data.core;
  v_cdr.yeti_version=v_version_data.yeti;
  v_cdr.lega_user_agent=v_version_data.aleg;
  v_cdr.legb_user_agent=v_version_data.bleg;

  v_cdr.pop_id=i_pop_id;
  v_cdr.node_id=i_node_id;

  v_cdr.src_name_in:=v_dynamic.src_name_in;
  v_cdr.src_name_out:=v_dynamic.src_name_out;

  v_cdr.diversion_in:=v_dynamic.diversion_in;
  v_cdr.diversion_out:=v_dynamic.diversion_out;

  v_cdr.customer_id:=v_dynamic.customer_id;
  v_cdr.customer_external_id:=v_dynamic.customer_external_id;

  v_cdr.customer_acc_id:=v_dynamic.customer_acc_id;
  v_cdr.customer_account_check_balance=v_dynamic.customer_acc_check_balance;
  v_cdr.customer_acc_external_id=v_dynamic.customer_acc_external_id;
  v_cdr.customer_acc_vat:=v_dynamic.customer_acc_vat;

  v_cdr.customer_auth_id:=v_dynamic.customer_auth_id;
  v_cdr.customer_auth_external_id:=v_dynamic.customer_auth_external_id;
  v_cdr.customer_auth_external_type:=v_dynamic.customer_auth_external_type;
  v_cdr.customer_auth_name:=v_dynamic.customer_auth_name;

  v_cdr.vendor_id:=v_dynamic.vendor_id;
  v_cdr.vendor_external_id:=v_dynamic.vendor_external_id;
  v_cdr.vendor_acc_id:=v_dynamic.vendor_acc_id;
  v_cdr.vendor_acc_external_id:=v_dynamic.vendor_acc_external_id;

  v_cdr.destination_id:=v_dynamic.destination_id;
  v_cdr.destination_prefix:=v_dynamic.destination_prefix;
  v_cdr.dialpeer_id:=v_dynamic.dialpeer_id;
  v_cdr.dialpeer_prefix:=v_dynamic.dialpeer_prefix;

  v_cdr.orig_gw_id:=v_dynamic.orig_gw_id;
  v_cdr.orig_gw_external_id:=v_dynamic.orig_gw_external_id;
  v_cdr.term_gw_id:=v_dynamic.term_gw_id;
  v_cdr.term_gw_external_id:=v_dynamic.term_gw_external_id;

  v_cdr.routing_group_id:=v_dynamic.routing_group_id;
  v_cdr.rateplan_id:=v_dynamic.rateplan_id;

  v_cdr.routing_attempt=i_routing_attempt;
  v_cdr.is_last_cdr=i_is_last_cdr;

  v_cdr.destination_initial_rate:=v_dynamic.destination_initial_rate::numeric;
  v_cdr.destination_next_rate:=v_dynamic.destination_next_rate::numeric;
  v_cdr.destination_initial_interval:=v_dynamic.destination_initial_interval;
  v_cdr.destination_next_interval:=v_dynamic.destination_next_interval;
  v_cdr.destination_fee:=v_dynamic.destination_fee;
  v_cdr.destination_rate_policy_id:=v_dynamic.destination_rate_policy_id;
  v_cdr.destination_reverse_billing=v_dynamic.destination_reverse_billing;

  v_cdr.dialpeer_initial_rate:=v_dynamic.dialpeer_initial_rate::numeric;
  v_cdr.dialpeer_next_rate:=v_dynamic.dialpeer_next_rate::numeric;
  v_cdr.dialpeer_initial_interval:=v_dynamic.dialpeer_initial_interval;
  v_cdr.dialpeer_next_interval:=v_dynamic.dialpeer_next_interval;
  v_cdr.dialpeer_fee:=v_dynamic.dialpeer_fee;
  v_cdr.dialpeer_reverse_billing=v_dynamic.dialpeer_reverse_billing;

  /* sockets addresses */
  v_cdr.sign_orig_transport_protocol_id=i_lega_transport_protocol_id;
  v_cdr.sign_orig_ip=i_lega_remote_ip;
  v_cdr.sign_orig_port=NULLIF(i_lega_remote_port,0);
  v_cdr.sign_orig_local_ip=i_lega_local_ip;
  v_cdr.sign_orig_local_port=NULLIF(i_lega_local_port,0);

  v_cdr.sign_term_transport_protocol_id=i_legb_transport_protocol_id;
  v_cdr.sign_term_ip=i_legb_remote_ip;
  v_cdr.sign_term_port=NULLIF(i_legb_remote_port,0);
  v_cdr.sign_term_local_ip=i_legb_local_ip;
  v_cdr.sign_term_local_port=NULLIF(i_legb_local_port,0);

  v_cdr.local_tag=i_local_tag;
  v_cdr.legb_local_tag=i_legb_local_tag;
  v_cdr.legb_ruri=i_legb_ruri;
  v_cdr.legb_outbound_proxy=i_legb_outbound_proxy;

  v_cdr.is_redirected=i_is_redirected;

  /* Call time data */
  v_cdr.time_start:=to_timestamp(v_time_data.time_start);

  select into strict v_config * from sys.config;

  if v_time_data.time_connect is not null then
    v_cdr.time_connect:=to_timestamp(v_time_data.time_connect);
    v_cdr.duration:=switch.duration_round(v_config, v_time_data.time_end-v_time_data.time_connect); -- rounding
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

  v_cdr.src_prefix_in:=v_dynamic.src_prefix_in;
  v_cdr.src_prefix_out:=v_dynamic.src_prefix_out;
  v_cdr.dst_prefix_in:=v_dynamic.dst_prefix_in;
  v_cdr.dst_prefix_out:=v_dynamic.dst_prefix_out;

  v_cdr.orig_call_id=i_orig_call_id;
  v_cdr.term_call_id=i_term_call_id;

  /* removed */
  --v_cdr.dump_file:=i_msg_logger_path;

  v_cdr.dump_level_id:=i_dump_level_id;
  v_cdr.audio_recorded:=i_audio_recorded;

  v_cdr.auth_orig_transport_protocol_id=v_dynamic.auth_orig_protocol_id;
  v_cdr.auth_orig_ip:=v_dynamic.auth_orig_ip;
  v_cdr.auth_orig_ip:=v_dynamic.auth_orig_ip;
  v_cdr.auth_orig_port:=v_dynamic.auth_orig_port;

  perform switch.write_rtp_statistics(
    i_rtp_statistics,
    i_pop_id,
    i_node_id,
    v_dynamic.orig_gw_id,
    v_dynamic.orig_gw_external_id,
    v_dynamic.term_gw_id,
    v_dynamic.term_gw_external_id,
    i_local_tag,
    i_legb_local_tag
  );

  v_cdr.global_tag=i_global_tag;

  v_cdr.src_country_id=v_dynamic.src_country_id;
  v_cdr.src_network_id=v_dynamic.src_network_id;
  v_cdr.dst_country_id=v_dynamic.dst_country_id;
  v_cdr.dst_network_id=v_dynamic.dst_network_id;
  v_cdr.dst_prefix_routing=v_dynamic.dst_prefix_routing;
  v_cdr.src_prefix_routing=v_dynamic.src_prefix_routing;
  v_cdr.routing_plan_id=v_dynamic.routing_plan_id;
  v_cdr.lrn=v_dynamic.lrn;
  v_cdr.lnp_database_id=v_dynamic.lnp_database_id;

  v_cdr.ruri_domain=v_dynamic.ruri_domain;
  v_cdr.to_domain=v_dynamic.to_domain;
  v_cdr.from_domain=v_dynamic.from_domain;

  v_cdr.src_area_id=v_dynamic.src_area_id;
  v_cdr.dst_area_id=v_dynamic.dst_area_id;
  v_cdr.routing_tag_ids=v_dynamic.routing_tag_ids;


  v_cdr.id:=nextval('cdr.cdr_id_seq'::regclass);
  v_cdr.uuid:=public.uuid_generate_v1();

  v_cdr.pai_in=v_dynamic.pai_in;
  v_cdr.ppi_in=v_dynamic.ppi_in;
  v_cdr.privacy_in=v_dynamic.privacy_in;
  v_cdr.rpid_in=v_dynamic.rpid_in;
  v_cdr.rpid_privacy_in=v_dynamic.rpid_privacy_in;
  v_cdr.pai_out=v_dynamic.pai_out;
  v_cdr.ppi_out=v_dynamic.ppi_out;
  v_cdr.privacy_out=v_dynamic.privacy_out;
  v_cdr.rpid_out=v_dynamic.rpid_out;
  v_cdr.rpid_privacy_out=v_dynamic.rpid_privacy_out;

  v_cdr.failed_resource_type_id = i_failed_resource_type_id;
  v_cdr.failed_resource_id = i_failed_resource_id;

  v_cdr:=billing.bill_cdr(v_cdr);

  if not v_config.disable_realtime_statistics then
    perform stats.update_rt_stats(v_cdr);
  end if;

  v_cdr.customer_price = switch.customer_price_round(v_config, v_cdr.customer_price);
  v_cdr.customer_price_no_vat = switch.customer_price_round(v_config, v_cdr.customer_price_no_vat);
  v_cdr.vendor_price = switch.vendor_price_round(v_config, v_cdr.vendor_price);

  -- generate event to billing engine
  perform event.billing_insert_event('cdr_full',v_cdr);
  perform event.streaming_insert_event(v_cdr);
  INSERT INTO cdr.cdr VALUES( v_cdr.*);
  RETURN 0;
END;
$$;

CREATE or replace FUNCTION switch.writecdr(i_is_master boolean, i_node_id integer, i_pop_id integer, i_routing_attempt integer, i_is_last_cdr boolean, i_lega_transport_protocol_id smallint, i_lega_local_ip character varying, i_lega_local_port integer, i_lega_remote_ip character varying, i_lega_remote_port integer, i_legb_transport_protocol_id smallint, i_legb_local_ip character varying, i_legb_local_port integer, i_legb_remote_ip character varying, i_legb_remote_port integer, i_legb_ruri character varying, i_legb_outbound_proxy character varying, i_time_data json, i_early_media_present boolean, i_legb_disconnect_code integer, i_legb_disconnect_reason character varying, i_disconnect_initiator integer, i_internal_disconnect_code integer, i_internal_disconnect_reason character varying, i_lega_disconnect_code integer, i_lega_disconnect_reason character varying, i_internal_disconnect_code_id smallint, i_orig_call_id character varying, i_term_call_id character varying, i_local_tag character varying, i_legb_local_tag character varying, i_msg_logger_path character varying, i_dump_level_id smallint, i_audio_recorded boolean, i_rtp_stats_data json, i_rtp_statistics json, i_global_tag character varying, i_resources character varying, i_active_resources json, i_failed_resource_type_id smallint, i_failed_resource_id bigint, i_dtmf_events json, i_versions json, i_is_redirected boolean, i_dynamic json, i_lega_headers json, i_legb_headers json, i_lega_identity json) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER COST 10
    AS $$
DECLARE
  v_cdr cdr.cdr%rowtype;

  v_time_data switch.time_data_ty;
  v_version_data switch.versions_ty;
  v_dynamic switch.dynamic_cdr_data_ty;

  v_nozerolen boolean;
  v_config sys.config%rowtype;

  v_rtp_rx_stream_data rtp_statistics.rx_streams%rowtype;
  v_rtp_tx_stream_data rtp_statistics.tx_streams%rowtype;

  v_lega_headers switch.lega_headers_ty;
  v_legb_headers switch.legb_headers_ty;
  v_lega_reason switch.reason_ty;
  v_legb_reason switch.reason_ty;
BEGIN
  --  raise warning 'type: % id: %', i_failed_resource_type_id, i_failed_resource_id;
  --  RAISE warning 'DTMF: %', i_dtmf_events;

  v_time_data:=json_populate_record(null::switch.time_data_ty, i_time_data);
  v_version_data:=json_populate_record(null::switch.versions_ty, i_versions);
  v_dynamic:=json_populate_record(null::switch.dynamic_cdr_data_ty, i_dynamic);

  v_lega_headers:=json_populate_record(null::switch.lega_headers_ty, i_lega_headers);
  v_legb_headers:=json_populate_record(null::switch.legb_headers_ty, i_legb_headers);

  v_cdr.p_charge_info_in = v_lega_headers.p_charge_info;

  v_lega_reason = v_lega_headers.reason;
  v_cdr.lega_q850_cause = v_lega_reason.q850_cause;
  v_cdr.lega_q850_text = v_lega_reason.q850_text;
  v_cdr.lega_q850_params = v_lega_reason.q850_params;

  v_legb_reason = v_legb_headers.reason;
  v_cdr.legb_q850_cause = v_legb_reason.q850_cause;
  v_cdr.legb_q850_text = v_legb_reason.q850_text;
  v_cdr.legb_q850_params = v_legb_reason.q850_params;

  v_cdr.lega_identity = i_lega_identity;
  v_cdr.lega_ss_status_id = v_dynamic.lega_ss_status_id;
  v_cdr.legb_ss_status_id = v_dynamic.legb_ss_status_id;

  v_cdr.metadata = v_dynamic.metadata::jsonb;

  v_cdr.core_version=v_version_data.core;
  v_cdr.yeti_version=v_version_data.yeti;
  v_cdr.lega_user_agent=v_version_data.aleg;
  v_cdr.legb_user_agent=v_version_data.bleg;

  v_cdr.pop_id=i_pop_id;
  v_cdr.node_id=i_node_id;

  v_cdr.src_name_in:=v_dynamic.src_name_in;
  v_cdr.src_name_out:=v_dynamic.src_name_out;

  v_cdr.diversion_in:=v_dynamic.diversion_in;
  v_cdr.diversion_out:=v_dynamic.diversion_out;

  v_cdr.customer_id:=v_dynamic.customer_id;
  v_cdr.customer_external_id:=v_dynamic.customer_external_id;

  v_cdr.customer_acc_id:=v_dynamic.customer_acc_id;
  v_cdr.customer_account_check_balance=v_dynamic.customer_acc_check_balance;
  v_cdr.customer_acc_external_id=v_dynamic.customer_acc_external_id;
  v_cdr.customer_acc_vat:=v_dynamic.customer_acc_vat;

  v_cdr.customer_auth_id:=v_dynamic.customer_auth_id;
  v_cdr.customer_auth_external_id:=v_dynamic.customer_auth_external_id;
  v_cdr.customer_auth_external_type:=v_dynamic.customer_auth_external_type;
  v_cdr.customer_auth_name:=v_dynamic.customer_auth_name;

  v_cdr.vendor_id:=v_dynamic.vendor_id;
  v_cdr.vendor_external_id:=v_dynamic.vendor_external_id;
  v_cdr.vendor_acc_id:=v_dynamic.vendor_acc_id;
  v_cdr.vendor_acc_external_id:=v_dynamic.vendor_acc_external_id;

  v_cdr.destination_id:=v_dynamic.destination_id;
  v_cdr.destination_prefix:=v_dynamic.destination_prefix;
  v_cdr.dialpeer_id:=v_dynamic.dialpeer_id;
  v_cdr.dialpeer_prefix:=v_dynamic.dialpeer_prefix;

  v_cdr.orig_gw_id:=v_dynamic.orig_gw_id;
  v_cdr.orig_gw_external_id:=v_dynamic.orig_gw_external_id;
  v_cdr.term_gw_id:=v_dynamic.term_gw_id;
  v_cdr.term_gw_external_id:=v_dynamic.term_gw_external_id;

  v_cdr.routing_group_id:=v_dynamic.routing_group_id;
  v_cdr.rateplan_id:=v_dynamic.rateplan_id;

  v_cdr.routing_attempt=i_routing_attempt;
  v_cdr.is_last_cdr=i_is_last_cdr;

  v_cdr.destination_initial_rate:=v_dynamic.destination_initial_rate::numeric;
  v_cdr.destination_next_rate:=v_dynamic.destination_next_rate::numeric;
  v_cdr.destination_initial_interval:=v_dynamic.destination_initial_interval;
  v_cdr.destination_next_interval:=v_dynamic.destination_next_interval;
  v_cdr.destination_fee:=v_dynamic.destination_fee;
  v_cdr.destination_rate_policy_id:=v_dynamic.destination_rate_policy_id;
  v_cdr.destination_reverse_billing=v_dynamic.destination_reverse_billing;

  v_cdr.dialpeer_initial_rate:=v_dynamic.dialpeer_initial_rate::numeric;
  v_cdr.dialpeer_next_rate:=v_dynamic.dialpeer_next_rate::numeric;
  v_cdr.dialpeer_initial_interval:=v_dynamic.dialpeer_initial_interval;
  v_cdr.dialpeer_next_interval:=v_dynamic.dialpeer_next_interval;
  v_cdr.dialpeer_fee:=v_dynamic.dialpeer_fee;
  v_cdr.dialpeer_reverse_billing=v_dynamic.dialpeer_reverse_billing;

  /* sockets addresses */
  v_cdr.sign_orig_transport_protocol_id=i_lega_transport_protocol_id;
  v_cdr.sign_orig_ip=i_lega_remote_ip;
  v_cdr.sign_orig_port=NULLIF(i_lega_remote_port,0);
  v_cdr.sign_orig_local_ip=i_lega_local_ip;
  v_cdr.sign_orig_local_port=NULLIF(i_lega_local_port,0);

  v_cdr.sign_term_transport_protocol_id=i_legb_transport_protocol_id;
  v_cdr.sign_term_ip=i_legb_remote_ip;
  v_cdr.sign_term_port=NULLIF(i_legb_remote_port,0);
  v_cdr.sign_term_local_ip=i_legb_local_ip;
  v_cdr.sign_term_local_port=NULLIF(i_legb_local_port,0);

  v_cdr.local_tag=i_local_tag;
  v_cdr.legb_local_tag=i_legb_local_tag;
  v_cdr.legb_ruri=i_legb_ruri;
  v_cdr.legb_outbound_proxy=i_legb_outbound_proxy;

  v_cdr.is_redirected=i_is_redirected;

  /* Call time data */
  v_cdr.time_start:=to_timestamp(v_time_data.time_start);

  select into strict v_config * from sys.config;

  if v_time_data.time_connect is not null then
    v_cdr.time_connect:=to_timestamp(v_time_data.time_connect);
    v_cdr.duration:=switch.duration_round(v_config, v_time_data.time_end-v_time_data.time_connect); -- rounding
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
  v_cdr.legb_disconnect_code=i_legb_disconnect_code;
  v_cdr.legb_disconnect_reason=i_legb_disconnect_reason;
  v_cdr.disconnect_initiator_id=i_disconnect_initiator;
  v_cdr.internal_disconnect_code_id=i_internal_disconnect_code_id;
  v_cdr.internal_disconnect_code=i_internal_disconnect_code;
  v_cdr.internal_disconnect_reason=i_internal_disconnect_reason;
  v_cdr.lega_disconnect_code=i_lega_disconnect_code;
  v_cdr.lega_disconnect_reason=i_lega_disconnect_reason;

  v_cdr.src_prefix_in:=v_dynamic.src_prefix_in;
  v_cdr.src_prefix_out:=v_dynamic.src_prefix_out;
  v_cdr.dst_prefix_in:=v_dynamic.dst_prefix_in;
  v_cdr.dst_prefix_out:=v_dynamic.dst_prefix_out;

  v_cdr.orig_call_id=i_orig_call_id;
  v_cdr.term_call_id=i_term_call_id;

  /* removed */
  --v_cdr.dump_file:=i_msg_logger_path;

  v_cdr.dump_level_id:=i_dump_level_id;
  v_cdr.audio_recorded:=i_audio_recorded;

  v_cdr.auth_orig_transport_protocol_id=v_dynamic.auth_orig_protocol_id;
  v_cdr.auth_orig_ip:=v_dynamic.auth_orig_ip;
  v_cdr.auth_orig_ip:=v_dynamic.auth_orig_ip;
  v_cdr.auth_orig_port:=v_dynamic.auth_orig_port;

  perform switch.write_rtp_statistics(
    i_rtp_statistics,
    i_pop_id,
    i_node_id,
    v_dynamic.orig_gw_id,
    v_dynamic.orig_gw_external_id,
    v_dynamic.term_gw_id,
    v_dynamic.term_gw_external_id,
    i_local_tag,
    i_legb_local_tag
  );

  v_cdr.global_tag=i_global_tag;

  v_cdr.src_country_id=v_dynamic.src_country_id;
  v_cdr.src_network_id=v_dynamic.src_network_id;
  v_cdr.dst_country_id=v_dynamic.dst_country_id;
  v_cdr.dst_network_id=v_dynamic.dst_network_id;
  v_cdr.dst_prefix_routing=v_dynamic.dst_prefix_routing;
  v_cdr.src_prefix_routing=v_dynamic.src_prefix_routing;
  v_cdr.routing_plan_id=v_dynamic.routing_plan_id;
  v_cdr.lrn=v_dynamic.lrn;
  v_cdr.lnp_database_id=v_dynamic.lnp_database_id;

  v_cdr.ruri_domain=v_dynamic.ruri_domain;
  v_cdr.to_domain=v_dynamic.to_domain;
  v_cdr.from_domain=v_dynamic.from_domain;

  v_cdr.src_area_id=v_dynamic.src_area_id;
  v_cdr.dst_area_id=v_dynamic.dst_area_id;
  v_cdr.routing_tag_ids=v_dynamic.routing_tag_ids;


  v_cdr.id:=nextval('cdr.cdr_id_seq'::regclass);
  v_cdr.uuid:=public.uuid_generate_v1();

  v_cdr.pai_in=v_dynamic.pai_in;
  v_cdr.ppi_in=v_dynamic.ppi_in;
  v_cdr.privacy_in=v_dynamic.privacy_in;
  v_cdr.rpid_in=v_dynamic.rpid_in;
  v_cdr.rpid_privacy_in=v_dynamic.rpid_privacy_in;
  v_cdr.pai_out=v_dynamic.pai_out;
  v_cdr.ppi_out=v_dynamic.ppi_out;
  v_cdr.privacy_out=v_dynamic.privacy_out;
  v_cdr.rpid_out=v_dynamic.rpid_out;
  v_cdr.rpid_privacy_out=v_dynamic.rpid_privacy_out;

  v_cdr.failed_resource_type_id = i_failed_resource_type_id;
  v_cdr.failed_resource_id = i_failed_resource_id;

  v_cdr:=billing.bill_cdr(v_cdr);

  if not v_config.disable_realtime_statistics then
    perform stats.update_rt_stats(v_cdr);
  end if;

  v_cdr.customer_price = switch.customer_price_round(v_config, v_cdr.customer_price);
  v_cdr.customer_price_no_vat = switch.customer_price_round(v_config, v_cdr.customer_price_no_vat);
  v_cdr.vendor_price = switch.vendor_price_round(v_config, v_cdr.vendor_price);

  -- generate event to billing engine
  perform event.billing_insert_event('cdr_full',v_cdr);
  perform event.streaming_insert_event(v_cdr);
  INSERT INTO cdr.cdr VALUES( v_cdr.*);
  RETURN 0;
END;
$$;



      alter table cdr.cdr drop column time_limit;
      alter table reports.cdr_interval_report_data drop column time_limit;
      alter table reports.cdr_custom_report_data drop column time_limit;

    }
  end

  def down
    execute %q{
      alter table cdr.cdr add time_limit varchar;
      alter table reports.cdr_interval_report_data add time_limit varchar;
      alter table reports.cdr_custom_report_data add time_limit varchar;

CREATE or replace  FUNCTION switch.writecdr(i_is_master boolean, i_node_id integer, i_pop_id integer, i_routing_attempt integer, i_is_last_cdr boolean, i_lega_transport_protocol_id smallint, i_lega_local_ip character varying, i_lega_local_port integer, i_lega_remote_ip character varying, i_lega_remote_port integer, i_legb_transport_protocol_id smallint, i_legb_local_ip character varying, i_legb_local_port integer, i_legb_remote_ip character varying, i_legb_remote_port integer, i_legb_ruri character varying, i_legb_outbound_proxy character varying, i_time_data json, i_early_media_present boolean, i_legb_disconnect_code integer, i_legb_disconnect_reason character varying, i_disconnect_initiator integer, i_internal_disconnect_code integer, i_internal_disconnect_reason character varying, i_lega_disconnect_code integer, i_lega_disconnect_reason character varying, i_orig_call_id character varying, i_term_call_id character varying, i_local_tag character varying, i_legb_local_tag character varying, i_msg_logger_path character varying, i_dump_level_id smallint, i_audio_recorded boolean, i_rtp_stats_data json, i_rtp_statistics json, i_global_tag character varying, i_resources character varying, i_active_resources json, i_failed_resource_type_id smallint, i_failed_resource_id bigint, i_dtmf_events json, i_versions json, i_is_redirected boolean, i_dynamic json, i_lega_headers json, i_legb_headers json, i_lega_identity json) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER COST 10
    AS $$
DECLARE
  v_cdr cdr.cdr%rowtype;

  v_time_data switch.time_data_ty;
  v_version_data switch.versions_ty;
  v_dynamic switch.dynamic_cdr_data_ty;

  v_nozerolen boolean;
  v_config sys.config%rowtype;

  v_rtp_rx_stream_data rtp_statistics.rx_streams%rowtype;
  v_rtp_tx_stream_data rtp_statistics.tx_streams%rowtype;

  v_lega_headers switch.lega_headers_ty;
  v_legb_headers switch.legb_headers_ty;
  v_lega_reason switch.reason_ty;
  v_legb_reason switch.reason_ty;
BEGIN
  --  raise warning 'type: % id: %', i_failed_resource_type_id, i_failed_resource_id;
  --  RAISE warning 'DTMF: %', i_dtmf_events;

  v_time_data:=json_populate_record(null::switch.time_data_ty, i_time_data);
  v_version_data:=json_populate_record(null::switch.versions_ty, i_versions);
  v_dynamic:=json_populate_record(null::switch.dynamic_cdr_data_ty, i_dynamic);

  v_lega_headers:=json_populate_record(null::switch.lega_headers_ty, i_lega_headers);
  v_legb_headers:=json_populate_record(null::switch.legb_headers_ty, i_legb_headers);

  v_cdr.p_charge_info_in = v_lega_headers.p_charge_info;

  v_lega_reason = v_lega_headers.reason;
  v_cdr.lega_q850_cause = v_lega_reason.q850_cause;
  v_cdr.lega_q850_text = v_lega_reason.q850_text;
  v_cdr.lega_q850_params = v_lega_reason.q850_params;

  v_legb_reason = v_legb_headers.reason;
  v_cdr.legb_q850_cause = v_legb_reason.q850_cause;
  v_cdr.legb_q850_text = v_legb_reason.q850_text;
  v_cdr.legb_q850_params = v_legb_reason.q850_params;

  v_cdr.lega_identity = i_lega_identity;
  v_cdr.lega_ss_status_id = v_dynamic.lega_ss_status_id;
  v_cdr.legb_ss_status_id = v_dynamic.legb_ss_status_id;

  v_cdr.metadata = v_dynamic.metadata::jsonb;

  v_cdr.core_version=v_version_data.core;
  v_cdr.yeti_version=v_version_data.yeti;
  v_cdr.lega_user_agent=v_version_data.aleg;
  v_cdr.legb_user_agent=v_version_data.bleg;

  v_cdr.pop_id=i_pop_id;
  v_cdr.node_id=i_node_id;

  v_cdr.src_name_in:=v_dynamic.src_name_in;
  v_cdr.src_name_out:=v_dynamic.src_name_out;

  v_cdr.diversion_in:=v_dynamic.diversion_in;
  v_cdr.diversion_out:=v_dynamic.diversion_out;

  v_cdr.customer_id:=v_dynamic.customer_id;
  v_cdr.customer_external_id:=v_dynamic.customer_external_id;

  v_cdr.customer_acc_id:=v_dynamic.customer_acc_id;
  v_cdr.customer_account_check_balance=v_dynamic.customer_acc_check_balance;
  v_cdr.customer_acc_external_id=v_dynamic.customer_acc_external_id;
  v_cdr.customer_acc_vat:=v_dynamic.customer_acc_vat;

  v_cdr.customer_auth_id:=v_dynamic.customer_auth_id;
  v_cdr.customer_auth_external_id:=v_dynamic.customer_auth_external_id;
  v_cdr.customer_auth_external_type:=v_dynamic.customer_auth_external_type;
  v_cdr.customer_auth_name:=v_dynamic.customer_auth_name;

  v_cdr.vendor_id:=v_dynamic.vendor_id;
  v_cdr.vendor_external_id:=v_dynamic.vendor_external_id;
  v_cdr.vendor_acc_id:=v_dynamic.vendor_acc_id;
  v_cdr.vendor_acc_external_id:=v_dynamic.vendor_acc_external_id;

  v_cdr.destination_id:=v_dynamic.destination_id;
  v_cdr.destination_prefix:=v_dynamic.destination_prefix;
  v_cdr.dialpeer_id:=v_dynamic.dialpeer_id;
  v_cdr.dialpeer_prefix:=v_dynamic.dialpeer_prefix;

  v_cdr.orig_gw_id:=v_dynamic.orig_gw_id;
  v_cdr.orig_gw_external_id:=v_dynamic.orig_gw_external_id;
  v_cdr.term_gw_id:=v_dynamic.term_gw_id;
  v_cdr.term_gw_external_id:=v_dynamic.term_gw_external_id;

  v_cdr.routing_group_id:=v_dynamic.routing_group_id;
  v_cdr.rateplan_id:=v_dynamic.rateplan_id;

  v_cdr.routing_attempt=i_routing_attempt;
  v_cdr.is_last_cdr=i_is_last_cdr;

  v_cdr.destination_initial_rate:=v_dynamic.destination_initial_rate::numeric;
  v_cdr.destination_next_rate:=v_dynamic.destination_next_rate::numeric;
  v_cdr.destination_initial_interval:=v_dynamic.destination_initial_interval;
  v_cdr.destination_next_interval:=v_dynamic.destination_next_interval;
  v_cdr.destination_fee:=v_dynamic.destination_fee;
  v_cdr.destination_rate_policy_id:=v_dynamic.destination_rate_policy_id;
  v_cdr.destination_reverse_billing=v_dynamic.destination_reverse_billing;

  v_cdr.dialpeer_initial_rate:=v_dynamic.dialpeer_initial_rate::numeric;
  v_cdr.dialpeer_next_rate:=v_dynamic.dialpeer_next_rate::numeric;
  v_cdr.dialpeer_initial_interval:=v_dynamic.dialpeer_initial_interval;
  v_cdr.dialpeer_next_interval:=v_dynamic.dialpeer_next_interval;
  v_cdr.dialpeer_fee:=v_dynamic.dialpeer_fee;
  v_cdr.dialpeer_reverse_billing=v_dynamic.dialpeer_reverse_billing;

  /* sockets addresses */
  v_cdr.sign_orig_transport_protocol_id=i_lega_transport_protocol_id;
  v_cdr.sign_orig_ip=i_lega_remote_ip;
  v_cdr.sign_orig_port=NULLIF(i_lega_remote_port,0);
  v_cdr.sign_orig_local_ip=i_lega_local_ip;
  v_cdr.sign_orig_local_port=NULLIF(i_lega_local_port,0);

  v_cdr.sign_term_transport_protocol_id=i_legb_transport_protocol_id;
  v_cdr.sign_term_ip=i_legb_remote_ip;
  v_cdr.sign_term_port=NULLIF(i_legb_remote_port,0);
  v_cdr.sign_term_local_ip=i_legb_local_ip;
  v_cdr.sign_term_local_port=NULLIF(i_legb_local_port,0);

  v_cdr.local_tag=i_local_tag;
  v_cdr.legb_local_tag=i_legb_local_tag;
  v_cdr.legb_ruri=i_legb_ruri;
  v_cdr.legb_outbound_proxy=i_legb_outbound_proxy;

  v_cdr.is_redirected=i_is_redirected;

  /* Call time data */
  v_cdr.time_start:=to_timestamp(v_time_data.time_start);
  v_cdr.time_limit:=v_time_data.time_limit;

  select into strict v_config * from sys.config;

  if v_time_data.time_connect is not null then
    v_cdr.time_connect:=to_timestamp(v_time_data.time_connect);
    v_cdr.duration:=switch.duration_round(v_config, v_time_data.time_end-v_time_data.time_connect); -- rounding
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

  v_cdr.src_prefix_in:=v_dynamic.src_prefix_in;
  v_cdr.src_prefix_out:=v_dynamic.src_prefix_out;
  v_cdr.dst_prefix_in:=v_dynamic.dst_prefix_in;
  v_cdr.dst_prefix_out:=v_dynamic.dst_prefix_out;

  v_cdr.orig_call_id=i_orig_call_id;
  v_cdr.term_call_id=i_term_call_id;

  /* removed */
  --v_cdr.dump_file:=i_msg_logger_path;

  v_cdr.dump_level_id:=i_dump_level_id;
  v_cdr.audio_recorded:=i_audio_recorded;

  v_cdr.auth_orig_transport_protocol_id=v_dynamic.auth_orig_protocol_id;
  v_cdr.auth_orig_ip:=v_dynamic.auth_orig_ip;
  v_cdr.auth_orig_ip:=v_dynamic.auth_orig_ip;
  v_cdr.auth_orig_port:=v_dynamic.auth_orig_port;

  perform switch.write_rtp_statistics(
    i_rtp_statistics,
    i_pop_id,
    i_node_id,
    v_dynamic.orig_gw_id,
    v_dynamic.orig_gw_external_id,
    v_dynamic.term_gw_id,
    v_dynamic.term_gw_external_id,
    i_local_tag,
    i_legb_local_tag
  );

  v_cdr.global_tag=i_global_tag;

  v_cdr.src_country_id=v_dynamic.src_country_id;
  v_cdr.src_network_id=v_dynamic.src_network_id;
  v_cdr.dst_country_id=v_dynamic.dst_country_id;
  v_cdr.dst_network_id=v_dynamic.dst_network_id;
  v_cdr.dst_prefix_routing=v_dynamic.dst_prefix_routing;
  v_cdr.src_prefix_routing=v_dynamic.src_prefix_routing;
  v_cdr.routing_plan_id=v_dynamic.routing_plan_id;
  v_cdr.lrn=v_dynamic.lrn;
  v_cdr.lnp_database_id=v_dynamic.lnp_database_id;

  v_cdr.ruri_domain=v_dynamic.ruri_domain;
  v_cdr.to_domain=v_dynamic.to_domain;
  v_cdr.from_domain=v_dynamic.from_domain;

  v_cdr.src_area_id=v_dynamic.src_area_id;
  v_cdr.dst_area_id=v_dynamic.dst_area_id;
  v_cdr.routing_tag_ids=v_dynamic.routing_tag_ids;


  v_cdr.id:=nextval('cdr.cdr_id_seq'::regclass);
  v_cdr.uuid:=public.uuid_generate_v1();

  v_cdr.pai_in=v_dynamic.pai_in;
  v_cdr.ppi_in=v_dynamic.ppi_in;
  v_cdr.privacy_in=v_dynamic.privacy_in;
  v_cdr.rpid_in=v_dynamic.rpid_in;
  v_cdr.rpid_privacy_in=v_dynamic.rpid_privacy_in;
  v_cdr.pai_out=v_dynamic.pai_out;
  v_cdr.ppi_out=v_dynamic.ppi_out;
  v_cdr.privacy_out=v_dynamic.privacy_out;
  v_cdr.rpid_out=v_dynamic.rpid_out;
  v_cdr.rpid_privacy_out=v_dynamic.rpid_privacy_out;

  v_cdr.failed_resource_type_id = i_failed_resource_type_id;
  v_cdr.failed_resource_id = i_failed_resource_id;

  v_cdr:=billing.bill_cdr(v_cdr);

  if not v_config.disable_realtime_statistics then
    perform stats.update_rt_stats(v_cdr);
  end if;

  v_cdr.customer_price = switch.customer_price_round(v_config, v_cdr.customer_price);
  v_cdr.customer_price_no_vat = switch.customer_price_round(v_config, v_cdr.customer_price_no_vat);
  v_cdr.vendor_price = switch.vendor_price_round(v_config, v_cdr.vendor_price);

  -- generate event to billing engine
  perform event.billing_insert_event('cdr_full',v_cdr);
  perform event.streaming_insert_event(v_cdr);
  INSERT INTO cdr.cdr VALUES( v_cdr.*);
  RETURN 0;
END;
$$;


CREATE or replace FUNCTION switch.writecdr(i_is_master boolean, i_node_id integer, i_pop_id integer, i_routing_attempt integer, i_is_last_cdr boolean, i_lega_transport_protocol_id smallint, i_lega_local_ip character varying, i_lega_local_port integer, i_lega_remote_ip character varying, i_lega_remote_port integer, i_legb_transport_protocol_id smallint, i_legb_local_ip character varying, i_legb_local_port integer, i_legb_remote_ip character varying, i_legb_remote_port integer, i_legb_ruri character varying, i_legb_outbound_proxy character varying, i_time_data json, i_early_media_present boolean, i_legb_disconnect_code integer, i_legb_disconnect_reason character varying, i_disconnect_initiator integer, i_internal_disconnect_code integer, i_internal_disconnect_reason character varying, i_lega_disconnect_code integer, i_lega_disconnect_reason character varying, i_internal_disconnect_code_id smallint, i_orig_call_id character varying, i_term_call_id character varying, i_local_tag character varying, i_legb_local_tag character varying, i_msg_logger_path character varying, i_dump_level_id smallint, i_audio_recorded boolean, i_rtp_stats_data json, i_rtp_statistics json, i_global_tag character varying, i_resources character varying, i_active_resources json, i_failed_resource_type_id smallint, i_failed_resource_id bigint, i_dtmf_events json, i_versions json, i_is_redirected boolean, i_dynamic json, i_lega_headers json, i_legb_headers json, i_lega_identity json) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER COST 10
    AS $$
DECLARE
  v_cdr cdr.cdr%rowtype;

  v_time_data switch.time_data_ty;
  v_version_data switch.versions_ty;
  v_dynamic switch.dynamic_cdr_data_ty;

  v_nozerolen boolean;
  v_config sys.config%rowtype;

  v_rtp_rx_stream_data rtp_statistics.rx_streams%rowtype;
  v_rtp_tx_stream_data rtp_statistics.tx_streams%rowtype;

  v_lega_headers switch.lega_headers_ty;
  v_legb_headers switch.legb_headers_ty;
  v_lega_reason switch.reason_ty;
  v_legb_reason switch.reason_ty;
BEGIN
  --  raise warning 'type: % id: %', i_failed_resource_type_id, i_failed_resource_id;
  --  RAISE warning 'DTMF: %', i_dtmf_events;

  v_time_data:=json_populate_record(null::switch.time_data_ty, i_time_data);
  v_version_data:=json_populate_record(null::switch.versions_ty, i_versions);
  v_dynamic:=json_populate_record(null::switch.dynamic_cdr_data_ty, i_dynamic);

  v_lega_headers:=json_populate_record(null::switch.lega_headers_ty, i_lega_headers);
  v_legb_headers:=json_populate_record(null::switch.legb_headers_ty, i_legb_headers);

  v_cdr.p_charge_info_in = v_lega_headers.p_charge_info;

  v_lega_reason = v_lega_headers.reason;
  v_cdr.lega_q850_cause = v_lega_reason.q850_cause;
  v_cdr.lega_q850_text = v_lega_reason.q850_text;
  v_cdr.lega_q850_params = v_lega_reason.q850_params;

  v_legb_reason = v_legb_headers.reason;
  v_cdr.legb_q850_cause = v_legb_reason.q850_cause;
  v_cdr.legb_q850_text = v_legb_reason.q850_text;
  v_cdr.legb_q850_params = v_legb_reason.q850_params;

  v_cdr.lega_identity = i_lega_identity;
  v_cdr.lega_ss_status_id = v_dynamic.lega_ss_status_id;
  v_cdr.legb_ss_status_id = v_dynamic.legb_ss_status_id;

  v_cdr.metadata = v_dynamic.metadata::jsonb;

  v_cdr.core_version=v_version_data.core;
  v_cdr.yeti_version=v_version_data.yeti;
  v_cdr.lega_user_agent=v_version_data.aleg;
  v_cdr.legb_user_agent=v_version_data.bleg;

  v_cdr.pop_id=i_pop_id;
  v_cdr.node_id=i_node_id;

  v_cdr.src_name_in:=v_dynamic.src_name_in;
  v_cdr.src_name_out:=v_dynamic.src_name_out;

  v_cdr.diversion_in:=v_dynamic.diversion_in;
  v_cdr.diversion_out:=v_dynamic.diversion_out;

  v_cdr.customer_id:=v_dynamic.customer_id;
  v_cdr.customer_external_id:=v_dynamic.customer_external_id;

  v_cdr.customer_acc_id:=v_dynamic.customer_acc_id;
  v_cdr.customer_account_check_balance=v_dynamic.customer_acc_check_balance;
  v_cdr.customer_acc_external_id=v_dynamic.customer_acc_external_id;
  v_cdr.customer_acc_vat:=v_dynamic.customer_acc_vat;

  v_cdr.customer_auth_id:=v_dynamic.customer_auth_id;
  v_cdr.customer_auth_external_id:=v_dynamic.customer_auth_external_id;
  v_cdr.customer_auth_external_type:=v_dynamic.customer_auth_external_type;
  v_cdr.customer_auth_name:=v_dynamic.customer_auth_name;

  v_cdr.vendor_id:=v_dynamic.vendor_id;
  v_cdr.vendor_external_id:=v_dynamic.vendor_external_id;
  v_cdr.vendor_acc_id:=v_dynamic.vendor_acc_id;
  v_cdr.vendor_acc_external_id:=v_dynamic.vendor_acc_external_id;

  v_cdr.destination_id:=v_dynamic.destination_id;
  v_cdr.destination_prefix:=v_dynamic.destination_prefix;
  v_cdr.dialpeer_id:=v_dynamic.dialpeer_id;
  v_cdr.dialpeer_prefix:=v_dynamic.dialpeer_prefix;

  v_cdr.orig_gw_id:=v_dynamic.orig_gw_id;
  v_cdr.orig_gw_external_id:=v_dynamic.orig_gw_external_id;
  v_cdr.term_gw_id:=v_dynamic.term_gw_id;
  v_cdr.term_gw_external_id:=v_dynamic.term_gw_external_id;

  v_cdr.routing_group_id:=v_dynamic.routing_group_id;
  v_cdr.rateplan_id:=v_dynamic.rateplan_id;

  v_cdr.routing_attempt=i_routing_attempt;
  v_cdr.is_last_cdr=i_is_last_cdr;

  v_cdr.destination_initial_rate:=v_dynamic.destination_initial_rate::numeric;
  v_cdr.destination_next_rate:=v_dynamic.destination_next_rate::numeric;
  v_cdr.destination_initial_interval:=v_dynamic.destination_initial_interval;
  v_cdr.destination_next_interval:=v_dynamic.destination_next_interval;
  v_cdr.destination_fee:=v_dynamic.destination_fee;
  v_cdr.destination_rate_policy_id:=v_dynamic.destination_rate_policy_id;
  v_cdr.destination_reverse_billing=v_dynamic.destination_reverse_billing;

  v_cdr.dialpeer_initial_rate:=v_dynamic.dialpeer_initial_rate::numeric;
  v_cdr.dialpeer_next_rate:=v_dynamic.dialpeer_next_rate::numeric;
  v_cdr.dialpeer_initial_interval:=v_dynamic.dialpeer_initial_interval;
  v_cdr.dialpeer_next_interval:=v_dynamic.dialpeer_next_interval;
  v_cdr.dialpeer_fee:=v_dynamic.dialpeer_fee;
  v_cdr.dialpeer_reverse_billing=v_dynamic.dialpeer_reverse_billing;

  /* sockets addresses */
  v_cdr.sign_orig_transport_protocol_id=i_lega_transport_protocol_id;
  v_cdr.sign_orig_ip=i_lega_remote_ip;
  v_cdr.sign_orig_port=NULLIF(i_lega_remote_port,0);
  v_cdr.sign_orig_local_ip=i_lega_local_ip;
  v_cdr.sign_orig_local_port=NULLIF(i_lega_local_port,0);

  v_cdr.sign_term_transport_protocol_id=i_legb_transport_protocol_id;
  v_cdr.sign_term_ip=i_legb_remote_ip;
  v_cdr.sign_term_port=NULLIF(i_legb_remote_port,0);
  v_cdr.sign_term_local_ip=i_legb_local_ip;
  v_cdr.sign_term_local_port=NULLIF(i_legb_local_port,0);

  v_cdr.local_tag=i_local_tag;
  v_cdr.legb_local_tag=i_legb_local_tag;
  v_cdr.legb_ruri=i_legb_ruri;
  v_cdr.legb_outbound_proxy=i_legb_outbound_proxy;

  v_cdr.is_redirected=i_is_redirected;

  /* Call time data */
  v_cdr.time_start:=to_timestamp(v_time_data.time_start);
  v_cdr.time_limit:=v_time_data.time_limit;

  select into strict v_config * from sys.config;

  if v_time_data.time_connect is not null then
    v_cdr.time_connect:=to_timestamp(v_time_data.time_connect);
    v_cdr.duration:=switch.duration_round(v_config, v_time_data.time_end-v_time_data.time_connect); -- rounding
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
  v_cdr.legb_disconnect_code=i_legb_disconnect_code;
  v_cdr.legb_disconnect_reason=i_legb_disconnect_reason;
  v_cdr.disconnect_initiator_id=i_disconnect_initiator;
  v_cdr.internal_disconnect_code_id=i_internal_disconnect_code_id;
  v_cdr.internal_disconnect_code=i_internal_disconnect_code;
  v_cdr.internal_disconnect_reason=i_internal_disconnect_reason;
  v_cdr.lega_disconnect_code=i_lega_disconnect_code;
  v_cdr.lega_disconnect_reason=i_lega_disconnect_reason;

  v_cdr.src_prefix_in:=v_dynamic.src_prefix_in;
  v_cdr.src_prefix_out:=v_dynamic.src_prefix_out;
  v_cdr.dst_prefix_in:=v_dynamic.dst_prefix_in;
  v_cdr.dst_prefix_out:=v_dynamic.dst_prefix_out;

  v_cdr.orig_call_id=i_orig_call_id;
  v_cdr.term_call_id=i_term_call_id;

  /* removed */
  --v_cdr.dump_file:=i_msg_logger_path;

  v_cdr.dump_level_id:=i_dump_level_id;
  v_cdr.audio_recorded:=i_audio_recorded;

  v_cdr.auth_orig_transport_protocol_id=v_dynamic.auth_orig_protocol_id;
  v_cdr.auth_orig_ip:=v_dynamic.auth_orig_ip;
  v_cdr.auth_orig_ip:=v_dynamic.auth_orig_ip;
  v_cdr.auth_orig_port:=v_dynamic.auth_orig_port;

  perform switch.write_rtp_statistics(
    i_rtp_statistics,
    i_pop_id,
    i_node_id,
    v_dynamic.orig_gw_id,
    v_dynamic.orig_gw_external_id,
    v_dynamic.term_gw_id,
    v_dynamic.term_gw_external_id,
    i_local_tag,
    i_legb_local_tag
  );

  v_cdr.global_tag=i_global_tag;

  v_cdr.src_country_id=v_dynamic.src_country_id;
  v_cdr.src_network_id=v_dynamic.src_network_id;
  v_cdr.dst_country_id=v_dynamic.dst_country_id;
  v_cdr.dst_network_id=v_dynamic.dst_network_id;
  v_cdr.dst_prefix_routing=v_dynamic.dst_prefix_routing;
  v_cdr.src_prefix_routing=v_dynamic.src_prefix_routing;
  v_cdr.routing_plan_id=v_dynamic.routing_plan_id;
  v_cdr.lrn=v_dynamic.lrn;
  v_cdr.lnp_database_id=v_dynamic.lnp_database_id;

  v_cdr.ruri_domain=v_dynamic.ruri_domain;
  v_cdr.to_domain=v_dynamic.to_domain;
  v_cdr.from_domain=v_dynamic.from_domain;

  v_cdr.src_area_id=v_dynamic.src_area_id;
  v_cdr.dst_area_id=v_dynamic.dst_area_id;
  v_cdr.routing_tag_ids=v_dynamic.routing_tag_ids;


  v_cdr.id:=nextval('cdr.cdr_id_seq'::regclass);
  v_cdr.uuid:=public.uuid_generate_v1();

  v_cdr.pai_in=v_dynamic.pai_in;
  v_cdr.ppi_in=v_dynamic.ppi_in;
  v_cdr.privacy_in=v_dynamic.privacy_in;
  v_cdr.rpid_in=v_dynamic.rpid_in;
  v_cdr.rpid_privacy_in=v_dynamic.rpid_privacy_in;
  v_cdr.pai_out=v_dynamic.pai_out;
  v_cdr.ppi_out=v_dynamic.ppi_out;
  v_cdr.privacy_out=v_dynamic.privacy_out;
  v_cdr.rpid_out=v_dynamic.rpid_out;
  v_cdr.rpid_privacy_out=v_dynamic.rpid_privacy_out;

  v_cdr.failed_resource_type_id = i_failed_resource_type_id;
  v_cdr.failed_resource_id = i_failed_resource_id;

  v_cdr:=billing.bill_cdr(v_cdr);

  if not v_config.disable_realtime_statistics then
    perform stats.update_rt_stats(v_cdr);
  end if;

  v_cdr.customer_price = switch.customer_price_round(v_config, v_cdr.customer_price);
  v_cdr.customer_price_no_vat = switch.customer_price_round(v_config, v_cdr.customer_price_no_vat);
  v_cdr.vendor_price = switch.vendor_price_round(v_config, v_cdr.vendor_price);

  -- generate event to billing engine
  perform event.billing_insert_event('cdr_full',v_cdr);
  perform event.streaming_insert_event(v_cdr);
  INSERT INTO cdr.cdr VALUES( v_cdr.*);
  RETURN 0;
END;
$$;

    }
  end
end
