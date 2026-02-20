class FixPddCalculations < ActiveRecord::Migration[7.2]

  def up
    execute %q{


CREATE OR REPLACE FUNCTION switch.writecdr(i_is_master boolean, i_node_id integer, i_pop_id integer, i_routing_attempt integer, i_is_last_cdr boolean, i_lega_transport_protocol_id smallint, i_lega_local_ip inet, i_lega_local_port integer, i_lega_remote_ip inet, i_lega_remote_port integer, i_legb_transport_protocol_id smallint, i_legb_local_ip inet, i_legb_local_port integer, i_legb_remote_ip inet, i_legb_remote_port integer, i_legb_ruri character varying, i_legb_outbound_proxy character varying, i_time_data json, i_early_media_present boolean, i_legb_disconnect_code integer, i_legb_disconnect_reason character varying, i_disconnect_initiator integer, i_internal_disconnect_code integer, i_internal_disconnect_reason character varying, i_lega_disconnect_code integer, i_lega_disconnect_reason character varying, i_internal_disconnect_code_id smallint, i_orig_call_id character varying, i_term_call_id character varying, i_local_tag character varying, i_legb_local_tag character varying, i_msg_logger_path character varying, i_dump_level_id smallint, i_audio_recorded boolean, i_rtp_stats_data json, i_rtp_statistics json, i_global_tag character varying, i_resources character varying, i_active_resources json, i_failed_resource_type_id smallint, i_failed_resource_id bigint, i_dtmf_events json, i_versions json, i_is_redirected boolean, i_dynamic json, i_lega_request_headers json, i_legb_request_headers json, i_legb_reply_headers json, i_lega_identity json) RETURNS integer
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

  v_lega_request_headers switch.lega_request_headers_ty;
  v_legb_request_headers switch.legb_request_headers_ty;
  v_legb_reply_headers switch.legb_reply_headers_ty;
  v_lega_reason switch.reason_ty;
  v_legb_reason switch.reason_ty;
BEGIN
  --  raise warning 'type: % id: %', i_failed_resource_type_id, i_failed_resource_id;
  --  RAISE warning 'DTMF: %', i_dtmf_events;

  v_time_data:=json_populate_record(null::switch.time_data_ty, i_time_data);
  v_version_data:=json_populate_record(null::switch.versions_ty, i_versions);
  v_dynamic:=json_populate_record(null::switch.dynamic_cdr_data_ty, i_dynamic);

  v_lega_request_headers = json_populate_record(null::switch.lega_request_headers_ty, i_lega_request_headers);
  v_legb_request_headers = json_populate_record(null::switch.legb_request_headers_ty, i_legb_request_headers);
  v_legb_reply_headers = json_populate_record(null::switch.legb_reply_headers_ty, i_legb_reply_headers);

  v_cdr.p_charge_info_in = v_lega_request_headers.p_charge_info;

  v_lega_reason = v_lega_request_headers.reason;
  v_cdr.lega_q850_cause = v_lega_reason.q850_cause;
  v_cdr.lega_q850_text = v_lega_reason.q850_text;
  v_cdr.lega_q850_params = v_lega_reason.q850_params;

  v_legb_reason = v_legb_reply_headers.reason;
  v_cdr.legb_q850_cause = v_legb_reason.q850_cause;
  v_cdr.legb_q850_text = v_legb_reason.q850_text;
  v_cdr.legb_q850_params = v_legb_reason.q850_params;

  v_cdr.diversion_in = array_to_string(v_lega_request_headers.diversion, ',');
  v_cdr.pai_in = array_to_string(v_lega_request_headers.p_asserted_identity, ',');
  v_cdr.ppi_in = v_lega_request_headers.p_preferred_identity;
  v_cdr.privacy_in = array_to_string(v_lega_request_headers.privacy, ',');
  v_cdr.rpid_in = array_to_string(v_lega_request_headers.remote_party_id, ',');
  v_cdr.rpid_privacy_in = array_to_string(v_lega_request_headers.rpid_privacy, ',');

  v_cdr.diversion_out = array_to_string(v_legb_request_headers.diversion, ',');
  v_cdr.pai_out = array_to_string(v_legb_request_headers.p_asserted_identity, ',');
  v_cdr.ppi_out = v_legb_request_headers.p_preferred_identity;
  v_cdr.privacy_out = array_to_string(v_legb_request_headers.privacy, ',');
  v_cdr.rpid_out = array_to_string(v_legb_request_headers.remote_party_id, ',');
  v_cdr.rpid_privacy_out = array_to_string(v_legb_request_headers.rpid_privacy, ',');

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

  v_cdr.package_counter_id = v_dynamic.package_counter_id;

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

  v_cdr.destination_id:=v_dynamic.destination_id;
  v_cdr.destination_prefix:=v_dynamic.destination_prefix;
  v_cdr.destination_initial_rate:=v_dynamic.destination_initial_rate::numeric;
  v_cdr.destination_next_rate:=v_dynamic.destination_next_rate::numeric;
  v_cdr.destination_initial_interval:=v_dynamic.destination_initial_interval;
  v_cdr.destination_next_interval:=v_dynamic.destination_next_interval;
  v_cdr.destination_fee:=v_dynamic.destination_fee;
  v_cdr.destination_rate_policy_id:=v_dynamic.destination_rate_policy_id;
  v_cdr.destination_reverse_billing=COALESCE(v_dynamic.destination_reverse_billing, false);

  v_cdr.dialpeer_initial_rate:=v_dynamic.dialpeer_initial_rate::numeric;
  v_cdr.dialpeer_next_rate:=v_dynamic.dialpeer_next_rate::numeric;
  v_cdr.dialpeer_initial_interval:=v_dynamic.dialpeer_initial_interval;
  v_cdr.dialpeer_next_interval:=v_dynamic.dialpeer_next_interval;
  v_cdr.dialpeer_fee:=v_dynamic.dialpeer_fee;
  v_cdr.dialpeer_reverse_billing=COALESCE(v_dynamic.dialpeer_reverse_billing, false);

  /* sockets addresses */
  v_cdr.sign_orig_transport_protocol_id = i_lega_transport_protocol_id;
  v_cdr.sign_orig_ip = host(i_lega_remote_ip);
  v_cdr.sign_orig_port = NULLIF(i_lega_remote_port,0);
  v_cdr.sign_orig_local_ip = host(i_lega_local_ip);
  v_cdr.sign_orig_local_port = NULLIF(i_lega_local_port,0);

  v_cdr.sign_term_transport_protocol_id = i_legb_transport_protocol_id;
  v_cdr.sign_term_ip = host(i_legb_remote_ip);
  v_cdr.sign_term_port = NULLIF(i_legb_remote_port,0);
  v_cdr.sign_term_local_ip = host(i_legb_local_ip);
  v_cdr.sign_term_local_port = NULLIF(i_legb_local_port,0);

  v_cdr.local_tag = i_local_tag;
  v_cdr.legb_local_tag = i_legb_local_tag;
  v_cdr.legb_ruri = i_legb_ruri;
  v_cdr.legb_outbound_proxy = i_legb_outbound_proxy;

  v_cdr.is_redirected = i_is_redirected;

  /* Call time data */
  v_cdr.time_start = to_timestamp(v_time_data.time_start);

  select into strict v_config * from sys.config;

  if v_time_data.time_connect is not null then
    v_cdr.time_connect = to_timestamp(v_time_data.time_connect);
    v_cdr.duration = switch.duration_round(v_config, v_time_data.time_end-v_time_data.time_connect); -- rounding
    v_nozerolen = true;
    v_cdr.success = true;
    if v_config.cdo and v_dynamic.destination_cdo is not null and v_dynamic.destination_cdo !=0 and v_cdr.duration + v_dynamic.destination_cdo > 0 then
      v_cdr.cdo = v_dynamic.destination_cdo;
    end if;
  else
    v_cdr.time_connect = NULL;
    v_cdr.duration = 0;
    v_nozerolen = false;
    v_cdr.success = false;
  end if;
  v_cdr.routing_delay = (v_time_data.leg_b_time-v_time_data.time_start)::real;
  v_cdr.pdd = (coalesce(v_time_data.time_18x,v_time_data.time_connect)-v_time_data.leg_b_time)::real;
  v_cdr.rtt = (coalesce(v_time_data.time_1xx,v_time_data.time_18x,v_time_data.time_connect)-v_time_data.leg_b_time)::real;
  v_cdr.early_media_present = i_early_media_present;

  v_cdr.time_end = to_timestamp(v_time_data.time_end);

  -- DC processing
  v_cdr.legb_disconnect_code = i_legb_disconnect_code;
  v_cdr.legb_disconnect_reason = i_legb_disconnect_reason;
  v_cdr.disconnect_initiator_id = i_disconnect_initiator;
  v_cdr.internal_disconnect_code_id = i_internal_disconnect_code_id;
  v_cdr.internal_disconnect_code = i_internal_disconnect_code;
  v_cdr.internal_disconnect_reason = i_internal_disconnect_reason;
  v_cdr.lega_disconnect_code = i_lega_disconnect_code;
  v_cdr.lega_disconnect_reason = i_lega_disconnect_reason;

  v_cdr.src_prefix_in = v_dynamic.src_prefix_in;
  v_cdr.src_prefix_out = v_dynamic.src_prefix_out;
  v_cdr.dst_prefix_in = v_dynamic.dst_prefix_in;
  v_cdr.dst_prefix_out = v_dynamic.dst_prefix_out;

  v_cdr.orig_call_id = i_orig_call_id;
  v_cdr.term_call_id = i_term_call_id;

  /* removed */
  --v_cdr.dump_file = i_msg_logger_path;

  v_cdr.dump_level_id = i_dump_level_id;
  v_cdr.audio_recorded = i_audio_recorded;

  v_cdr.auth_orig_transport_protocol_id = v_dynamic.auth_orig_protocol_id;
  v_cdr.auth_orig_ip = v_dynamic.auth_orig_ip;
  v_cdr.auth_orig_ip = v_dynamic.auth_orig_ip;
  v_cdr.auth_orig_port = v_dynamic.auth_orig_port;
  v_cdr.auth_orig_lat = v_lega_request_headers.x_orig_lat;
  v_cdr.auth_orig_lon = v_lega_request_headers.x_orig_lon;

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

  v_cdr.global_tag = i_global_tag;

  v_cdr.src_country_id = v_dynamic.src_country_id;
  v_cdr.src_network_id = v_dynamic.src_network_id;
  v_cdr.src_network_type_id = v_dynamic.src_network_type_id;
  v_cdr.dst_country_id = v_dynamic.dst_country_id;
  v_cdr.dst_network_id = v_dynamic.dst_network_id;
  v_cdr.dst_network_type_id = v_dynamic.dst_network_type_id;

  v_cdr.dst_prefix_routing = v_dynamic.dst_prefix_routing;
  v_cdr.src_prefix_routing = v_dynamic.src_prefix_routing;
  v_cdr.routing_plan_id = v_dynamic.routing_plan_id;
  v_cdr.lrn = v_dynamic.lrn;
  v_cdr.lnp_database_id = v_dynamic.lnp_database_id;

  v_cdr.ruri_domain = v_dynamic.ruri_domain;
  v_cdr.to_domain = v_dynamic.to_domain;
  v_cdr.from_domain = v_dynamic.from_domain;

  v_cdr.src_area_id = v_dynamic.src_area_id;
  v_cdr.dst_area_id = v_dynamic.dst_area_id;
  v_cdr.routing_tag_ids = v_dynamic.routing_tag_ids;


  v_cdr.id = nextval('cdr.cdr_id_seq'::regclass);
  v_cdr.uuid = public.uuid_generate_v1();

  v_cdr.failed_resource_type_id = i_failed_resource_type_id;
  v_cdr.failed_resource_id = i_failed_resource_id;

  v_cdr = billing.bill_cdr(v_cdr);

  if not v_config.disable_realtime_statistics then
    perform stats.update_rt_stats(v_cdr);
  end if;

  v_cdr.customer_price = switch.customer_price_round(v_config, v_cdr.customer_price);
  v_cdr.customer_price_no_vat = switch.customer_price_round(v_config, v_cdr.customer_price_no_vat);
  v_cdr.vendor_price = switch.vendor_price_round(v_config, v_cdr.vendor_price);

  if v_cdr.destination_reverse_billing THEN
    v_cdr.profit = - v_cdr.customer_price;
  else
    v_cdr.profit = v_cdr.customer_price;
  end if;

  if v_cdr.dialpeer_reverse_billing THEN
    v_cdr.profit = v_cdr.profit + v_cdr.vendor_price;
  else
    v_cdr.profit = v_cdr.profit - v_cdr.vendor_price;
  end if;

  -- generate event to billing engine
  perform event.billing_insert_event('cdr_full',v_cdr);
  perform event.streaming_insert_event(v_cdr);
  INSERT INTO cdr.cdr VALUES( v_cdr.*);
  RETURN 0;
END;
$$;


    }
  end

  def down
    execute %q{


CREATE OR REPLACE FUNCTION switch.writecdr(i_is_master boolean, i_node_id integer, i_pop_id integer, i_routing_attempt integer, i_is_last_cdr boolean, i_lega_transport_protocol_id smallint, i_lega_local_ip inet, i_lega_local_port integer, i_lega_remote_ip inet, i_lega_remote_port integer, i_legb_transport_protocol_id smallint, i_legb_local_ip inet, i_legb_local_port integer, i_legb_remote_ip inet, i_legb_remote_port integer, i_legb_ruri character varying, i_legb_outbound_proxy character varying, i_time_data json, i_early_media_present boolean, i_legb_disconnect_code integer, i_legb_disconnect_reason character varying, i_disconnect_initiator integer, i_internal_disconnect_code integer, i_internal_disconnect_reason character varying, i_lega_disconnect_code integer, i_lega_disconnect_reason character varying, i_internal_disconnect_code_id smallint, i_orig_call_id character varying, i_term_call_id character varying, i_local_tag character varying, i_legb_local_tag character varying, i_msg_logger_path character varying, i_dump_level_id smallint, i_audio_recorded boolean, i_rtp_stats_data json, i_rtp_statistics json, i_global_tag character varying, i_resources character varying, i_active_resources json, i_failed_resource_type_id smallint, i_failed_resource_id bigint, i_dtmf_events json, i_versions json, i_is_redirected boolean, i_dynamic json, i_lega_request_headers json, i_legb_request_headers json, i_legb_reply_headers json, i_lega_identity json) RETURNS integer
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

  v_lega_request_headers switch.lega_request_headers_ty;
  v_legb_request_headers switch.legb_request_headers_ty;
  v_legb_reply_headers switch.legb_reply_headers_ty;
  v_lega_reason switch.reason_ty;
  v_legb_reason switch.reason_ty;
BEGIN
  --  raise warning 'type: % id: %', i_failed_resource_type_id, i_failed_resource_id;
  --  RAISE warning 'DTMF: %', i_dtmf_events;

  v_time_data:=json_populate_record(null::switch.time_data_ty, i_time_data);
  v_version_data:=json_populate_record(null::switch.versions_ty, i_versions);
  v_dynamic:=json_populate_record(null::switch.dynamic_cdr_data_ty, i_dynamic);

  v_lega_request_headers = json_populate_record(null::switch.lega_request_headers_ty, i_lega_request_headers);
  v_legb_request_headers = json_populate_record(null::switch.legb_request_headers_ty, i_legb_request_headers);
  v_legb_reply_headers = json_populate_record(null::switch.legb_reply_headers_ty, i_legb_reply_headers);

  v_cdr.p_charge_info_in = v_lega_request_headers.p_charge_info;

  v_lega_reason = v_lega_request_headers.reason;
  v_cdr.lega_q850_cause = v_lega_reason.q850_cause;
  v_cdr.lega_q850_text = v_lega_reason.q850_text;
  v_cdr.lega_q850_params = v_lega_reason.q850_params;

  v_legb_reason = v_legb_reply_headers.reason;
  v_cdr.legb_q850_cause = v_legb_reason.q850_cause;
  v_cdr.legb_q850_text = v_legb_reason.q850_text;
  v_cdr.legb_q850_params = v_legb_reason.q850_params;

  v_cdr.diversion_in = array_to_string(v_lega_request_headers.diversion, ',');
  v_cdr.pai_in = array_to_string(v_lega_request_headers.p_asserted_identity, ',');
  v_cdr.ppi_in = v_lega_request_headers.p_preferred_identity;
  v_cdr.privacy_in = array_to_string(v_lega_request_headers.privacy, ',');
  v_cdr.rpid_in = array_to_string(v_lega_request_headers.remote_party_id, ',');
  v_cdr.rpid_privacy_in = array_to_string(v_lega_request_headers.rpid_privacy, ',');

  v_cdr.diversion_out = array_to_string(v_legb_request_headers.diversion, ',');
  v_cdr.pai_out = array_to_string(v_legb_request_headers.p_asserted_identity, ',');
  v_cdr.ppi_out = v_legb_request_headers.p_preferred_identity;
  v_cdr.privacy_out = array_to_string(v_legb_request_headers.privacy, ',');
  v_cdr.rpid_out = array_to_string(v_legb_request_headers.remote_party_id, ',');
  v_cdr.rpid_privacy_out = array_to_string(v_legb_request_headers.rpid_privacy, ',');

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

  v_cdr.package_counter_id = v_dynamic.package_counter_id;

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

  v_cdr.destination_id:=v_dynamic.destination_id;
  v_cdr.destination_prefix:=v_dynamic.destination_prefix;
  v_cdr.destination_initial_rate:=v_dynamic.destination_initial_rate::numeric;
  v_cdr.destination_next_rate:=v_dynamic.destination_next_rate::numeric;
  v_cdr.destination_initial_interval:=v_dynamic.destination_initial_interval;
  v_cdr.destination_next_interval:=v_dynamic.destination_next_interval;
  v_cdr.destination_fee:=v_dynamic.destination_fee;
  v_cdr.destination_rate_policy_id:=v_dynamic.destination_rate_policy_id;
  v_cdr.destination_reverse_billing=COALESCE(v_dynamic.destination_reverse_billing, false);

  v_cdr.dialpeer_initial_rate:=v_dynamic.dialpeer_initial_rate::numeric;
  v_cdr.dialpeer_next_rate:=v_dynamic.dialpeer_next_rate::numeric;
  v_cdr.dialpeer_initial_interval:=v_dynamic.dialpeer_initial_interval;
  v_cdr.dialpeer_next_interval:=v_dynamic.dialpeer_next_interval;
  v_cdr.dialpeer_fee:=v_dynamic.dialpeer_fee;
  v_cdr.dialpeer_reverse_billing=COALESCE(v_dynamic.dialpeer_reverse_billing, false);

  /* sockets addresses */
  v_cdr.sign_orig_transport_protocol_id = i_lega_transport_protocol_id;
  v_cdr.sign_orig_ip = host(i_lega_remote_ip);
  v_cdr.sign_orig_port = NULLIF(i_lega_remote_port,0);
  v_cdr.sign_orig_local_ip = host(i_lega_local_ip);
  v_cdr.sign_orig_local_port = NULLIF(i_lega_local_port,0);

  v_cdr.sign_term_transport_protocol_id = i_legb_transport_protocol_id;
  v_cdr.sign_term_ip = host(i_legb_remote_ip);
  v_cdr.sign_term_port = NULLIF(i_legb_remote_port,0);
  v_cdr.sign_term_local_ip = host(i_legb_local_ip);
  v_cdr.sign_term_local_port = NULLIF(i_legb_local_port,0);

  v_cdr.local_tag = i_local_tag;
  v_cdr.legb_local_tag = i_legb_local_tag;
  v_cdr.legb_ruri = i_legb_ruri;
  v_cdr.legb_outbound_proxy = i_legb_outbound_proxy;

  v_cdr.is_redirected = i_is_redirected;

  /* Call time data */
  v_cdr.time_start = to_timestamp(v_time_data.time_start);

  select into strict v_config * from sys.config;

  if v_time_data.time_connect is not null then
    v_cdr.time_connect = to_timestamp(v_time_data.time_connect);
    v_cdr.duration = switch.duration_round(v_config, v_time_data.time_end-v_time_data.time_connect); -- rounding
    v_nozerolen = true;
    v_cdr.success = true;
    if v_config.cdo and v_dynamic.destination_cdo is not null and v_dynamic.destination_cdo !=0 and v_cdr.duration + v_dynamic.destination_cdo > 0 then
      v_cdr.cdo = v_dynamic.destination_cdo;
    end if;
  else
    v_cdr.time_connect = NULL;
    v_cdr.duration = 0;
    v_nozerolen = false;
    v_cdr.success = false;
  end if;
  v_cdr.routing_delay = (v_time_data.leg_b_time-v_time_data.time_start)::real;
  v_cdr.pdd = (coalesce(v_time_data.time_18x,v_time_data.time_connect)-v_time_data.time_start)::real;
  v_cdr.rtt = (coalesce(v_time_data.time_1xx,v_time_data.time_18x,v_time_data.time_connect)-v_time_data.leg_b_time)::real;
  v_cdr.early_media_present = i_early_media_present;

  v_cdr.time_end = to_timestamp(v_time_data.time_end);

  -- DC processing
  v_cdr.legb_disconnect_code = i_legb_disconnect_code;
  v_cdr.legb_disconnect_reason = i_legb_disconnect_reason;
  v_cdr.disconnect_initiator_id = i_disconnect_initiator;
  v_cdr.internal_disconnect_code_id = i_internal_disconnect_code_id;
  v_cdr.internal_disconnect_code = i_internal_disconnect_code;
  v_cdr.internal_disconnect_reason = i_internal_disconnect_reason;
  v_cdr.lega_disconnect_code = i_lega_disconnect_code;
  v_cdr.lega_disconnect_reason = i_lega_disconnect_reason;

  v_cdr.src_prefix_in = v_dynamic.src_prefix_in;
  v_cdr.src_prefix_out = v_dynamic.src_prefix_out;
  v_cdr.dst_prefix_in = v_dynamic.dst_prefix_in;
  v_cdr.dst_prefix_out = v_dynamic.dst_prefix_out;

  v_cdr.orig_call_id = i_orig_call_id;
  v_cdr.term_call_id = i_term_call_id;

  /* removed */
  --v_cdr.dump_file = i_msg_logger_path;

  v_cdr.dump_level_id = i_dump_level_id;
  v_cdr.audio_recorded = i_audio_recorded;

  v_cdr.auth_orig_transport_protocol_id = v_dynamic.auth_orig_protocol_id;
  v_cdr.auth_orig_ip = v_dynamic.auth_orig_ip;
  v_cdr.auth_orig_ip = v_dynamic.auth_orig_ip;
  v_cdr.auth_orig_port = v_dynamic.auth_orig_port;
  v_cdr.auth_orig_lat = v_lega_request_headers.x_orig_lat;
  v_cdr.auth_orig_lon = v_lega_request_headers.x_orig_lon;

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

  v_cdr.global_tag = i_global_tag;

  v_cdr.src_country_id = v_dynamic.src_country_id;
  v_cdr.src_network_id = v_dynamic.src_network_id;
  v_cdr.src_network_type_id = v_dynamic.src_network_type_id;
  v_cdr.dst_country_id = v_dynamic.dst_country_id;
  v_cdr.dst_network_id = v_dynamic.dst_network_id;
  v_cdr.dst_network_type_id = v_dynamic.dst_network_type_id;

  v_cdr.dst_prefix_routing = v_dynamic.dst_prefix_routing;
  v_cdr.src_prefix_routing = v_dynamic.src_prefix_routing;
  v_cdr.routing_plan_id = v_dynamic.routing_plan_id;
  v_cdr.lrn = v_dynamic.lrn;
  v_cdr.lnp_database_id = v_dynamic.lnp_database_id;

  v_cdr.ruri_domain = v_dynamic.ruri_domain;
  v_cdr.to_domain = v_dynamic.to_domain;
  v_cdr.from_domain = v_dynamic.from_domain;

  v_cdr.src_area_id = v_dynamic.src_area_id;
  v_cdr.dst_area_id = v_dynamic.dst_area_id;
  v_cdr.routing_tag_ids = v_dynamic.routing_tag_ids;


  v_cdr.id = nextval('cdr.cdr_id_seq'::regclass);
  v_cdr.uuid = public.uuid_generate_v1();

  v_cdr.failed_resource_type_id = i_failed_resource_type_id;
  v_cdr.failed_resource_id = i_failed_resource_id;

  v_cdr = billing.bill_cdr(v_cdr);

  if not v_config.disable_realtime_statistics then
    perform stats.update_rt_stats(v_cdr);
  end if;

  v_cdr.customer_price = switch.customer_price_round(v_config, v_cdr.customer_price);
  v_cdr.customer_price_no_vat = switch.customer_price_round(v_config, v_cdr.customer_price_no_vat);
  v_cdr.vendor_price = switch.vendor_price_round(v_config, v_cdr.vendor_price);

  if v_cdr.destination_reverse_billing THEN
    v_cdr.profit = - v_cdr.customer_price;
  else
    v_cdr.profit = v_cdr.customer_price;
  end if;

  if v_cdr.dialpeer_reverse_billing THEN
    v_cdr.profit = v_cdr.profit + v_cdr.vendor_price;
  else
    v_cdr.profit = v_cdr.profit - v_cdr.vendor_price;
  end if;

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
