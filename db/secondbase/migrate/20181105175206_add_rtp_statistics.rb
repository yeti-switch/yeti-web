class AddRtpStatistics < ActiveRecord::Migration[5.1]
  def up
    execute %q{
      alter table cdr.cdr add legb_local_tag varchar;

      create schema rtp_statistics;
      create type rtp_statistics.stream_ty as (
        local_tag varchar,
        time_start double precision,
        time_end double precision,
        rtcp_rtt_min float,
        rtcp_rtt_max float,
        rtcp_rtt_mean float,
        rtcp_rtt_std float,
        rx_rtcp_rr_count double precision,
        rx_rtcp_sr_count double precision,
        tx_rtcp_rr_count double precision,
        tx_rtcp_sr_count double precision,
        local_host varchar,
        local_port integer,
        remote_host varchar,
        remote_port integer,

        rx_ssrc double precision,
        rx_packets double precision,
        rx_bytes double precision,
        rx_total_lost double precision,

        rx_payloads_transcoded varchar,
        rx_payloads_relayed varchar,

        rx_decode_errors double precision,
        rx_out_of_buffer_errors double precision,
        rx_rtp_parse_errors double precision,

        rx_packet_delta_min float,
        rx_packet_delta_max float,
        rx_packet_delta_mean float,
        rx_packet_delta_std float,
        rx_packet_jitter_min float,
        rx_packet_jitter_max float,
        rx_packet_jitter_mean float,
        rx_packet_jitter_std float,
        rx_rtcp_jitter_min float,
        rx_rtcp_jitter_max float,
        rx_rtcp_jitter_mean float,
        rx_rtcp_jitter_std float,

        tx_ssrc double precision,
        tx_packets double precision,
        tx_bytes double precision,
        tx_total_lost double precision,

        tx_payloads_transcoded varchar,
        tx_payloads_relayed varchar,
        tx_rtcp_jitter_min float,
        tx_rtcp_jitter_max float,
        tx_rtcp_jitter_mean float,
        tx_rtcp_jitter_std float
    );
      create table rtp_statistics.streams(
        id bigserial primary key,
        time_start timestamptz,
        time_end timestamptz,
        pop_id integer not null,
        node_id integer not null,
        gateway_id bigint not null,
        gateway_external_id bigint,
        local_tag varchar,
        rtcp_rtt_min float,
        rtcp_rtt_max float,
        rtcp_rtt_mean float,
        rtcp_rtt_std float,
        rx_rtcp_rr_count bigint,
        rx_rtcp_sr_count bigint,
        tx_rtcp_rr_count bigint,
        tx_rtcp_sr_count bigint,
        local_host varchar,
        local_port integer,
        remote_host varchar,
        remote_port integer,
        rx_ssrc bigint,
        rx_packets bigint,
        rx_bytes bigint,
        rx_total_lost bigint,
        rx_payloads_transcoded varchar,
        rx_payloads_relayed varchar,
        rx_decode_errors bigint,
        rx_out_of_buffer_errors bigint,
        rx_rtp_parse_errors bigint,
        rx_packet_delta_min float,
        rx_packet_delta_max float,
        rx_packet_delta_mean float,
        rx_packet_delta_std float,
        rx_packet_jitter_min float,
        rx_packet_jitter_max float,
        rx_packet_jitter_mean float,
        rx_packet_jitter_std float,
        rx_rtcp_jitter_min float,
        rx_rtcp_jitter_max float,
        rx_rtcp_jitter_mean float,
        rx_rtcp_jitter_std float,
        tx_ssrc bigint,
        tx_packets bigint,
        tx_bytes bigint,
        tx_total_lost bigint,
        tx_payloads_transcoded varchar,
        tx_payloads_relayed varchar,
        tx_rtcp_jitter_min float,
        tx_rtcp_jitter_max float,
        tx_rtcp_jitter_mean float,
        tx_rtcp_jitter_std float
    );
    create index on rtp_statistics.streams using btree (local_tag);


select pgq.create_queue('rtp_statistics');

CREATE FUNCTION event.rtp_statistics_insert_event(ev_data anyelement) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
begin
    return pgq.insert_event('rtp_statistics', 'rtp_statistics', event.serialize(ev_data), null, null, null, null);
end;
$$;

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
    i_legb_local_tag character varying,
    i_msg_logger_path character varying,
    i_dump_level_id integer,
    i_audio_recorded boolean,
    i_rtp_stats_data json,
    i_rtp_statistics json,
    i_global_tag character varying,
    i_resources character varying,
    i_active_resources json,
    i_failed_resource_type_id smallint,
    i_failed_resource_id bigint,
    i_dtmf_events json,
    i_versions json,
    i_is_redirected boolean,
    i_dynamic json
)
  RETURNS integer AS
$BODY$
DECLARE
  v_cdr cdr.cdr%rowtype;
  v_billing_event billing.cdr_v2;

  v_rtp_stats_data switch.rtp_stats_data_ty;
  v_time_data switch.time_data_ty;
  v_version_data switch.versions_ty;
  v_dynamic switch.dynamic_cdr_data_ty;

  v_nozerolen boolean;
  v_config sys.config%rowtype;
  v_rtp_stream rtp_statistics.stream_ty;
  v_rtp_stream_data rtp_statistics.streams%rowtype;

BEGIN
  --  raise warning 'type: % id: %', i_failed_resource_type_id, i_failed_resource_id;
  --  RAISE warning 'DTMF: %', i_dtmf_events;

  v_time_data:=json_populate_record(null::switch.time_data_ty, i_time_data);
  v_version_data:=json_populate_record(null::switch.versions_ty, i_versions);
  v_dynamic:=json_populate_record(null::switch.dynamic_cdr_data_ty, i_dynamic);

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
  v_cdr.sign_orig_ip:=i_legA_remote_ip;
  v_cdr.sign_orig_port=i_legA_remote_port;
  v_cdr.sign_orig_local_ip:=i_legA_local_ip;
  v_cdr.sign_orig_local_port=i_legA_local_port;

  v_cdr.sign_term_transport_protocol_id=i_legb_transport_protocol_id;
  v_cdr.sign_term_ip:=i_legB_remote_ip;
  v_cdr.sign_term_port:=i_legB_remote_port;
  v_cdr.sign_term_local_ip:=i_legB_local_ip;
  v_cdr.sign_term_local_port:=i_legB_local_port;

  v_cdr.local_tag=i_local_tag;
  v_cdr.legb_local_tag=i_legb_local_tag;

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


  for v_rtp_stream IN select * from json_populate_recordset(null::rtp_statistics.stream_ty,i_rtp_statistics) LOOP

        v_rtp_stream_data.id=nextval('rtp_statistics.streams_id_seq'::regclass);

        v_rtp_stream_data.pop_id=i_pop_id;
        v_rtp_stream_data.node_id=i_node_id;
        v_rtp_stream_data.local_tag=v_rtp_stream.local_tag;

        if v_rtp_stream.local_tag = i_local_tag then
          v_rtp_stream_data.gateway_id = v_dynamic.orig_gw_id;
          v_rtp_stream_data.gateway_external_id = v_dynamic.orig_gw_external_id;
        else
          v_rtp_stream_data.gateway_id = v_dynamic.term_gw_id;
          v_rtp_stream_data.gateway_external_id = v_dynamic.term_gw_external_id;
        end if;

        v_rtp_stream_data.time_start=to_timestamp(v_rtp_stream.time_start);
        v_rtp_stream_data.time_end=to_timestamp(v_rtp_stream.time_end);

        v_rtp_stream_data.rtcp_rtt_min=v_rtp_stream.rtcp_rtt_min;
        v_rtp_stream_data.rtcp_rtt_max=v_rtp_stream.rtcp_rtt_max;
        v_rtp_stream_data.rtcp_rtt_mean=v_rtp_stream.rtcp_rtt_mean;
        v_rtp_stream_data.rtcp_rtt_std=v_rtp_stream.rtcp_rtt_std;
        v_rtp_stream_data.rx_rtcp_rr_count=v_rtp_stream.rx_rtcp_rr_count::bigint;
        v_rtp_stream_data.rx_rtcp_sr_count=v_rtp_stream.rx_rtcp_sr_count::bigint;
        v_rtp_stream_data.tx_rtcp_rr_count=v_rtp_stream.tx_rtcp_rr_count::bigint;
        v_rtp_stream_data.tx_rtcp_sr_count=v_rtp_stream.tx_rtcp_sr_count::bigint;

        v_rtp_stream_data.local_host=v_rtp_stream.local_host;
        v_rtp_stream_data.local_port=v_rtp_stream.local_port;
        v_rtp_stream_data.remote_host=v_rtp_stream.remote_host;
        v_rtp_stream_data.remote_port=v_rtp_stream.remote_port;

        v_rtp_stream_data.rx_ssrc=v_rtp_stream.rx_ssrc::bigint;
        v_rtp_stream_data.rx_packets=v_rtp_stream.rx_packets::bigint;
        v_rtp_stream_data.rx_bytes=v_rtp_stream.rx_bytes::bigint;
        v_rtp_stream_data.rx_total_lost=v_rtp_stream.rx_total_lost::bigint;

        v_rtp_stream_data.rx_payloads_transcoded=v_rtp_stream.rx_payloads_transcoded;
        v_rtp_stream_data.rx_payloads_relayed=v_rtp_stream.rx_payloads_relayed;

        v_rtp_stream_data.rx_decode_errors=v_rtp_stream.rx_decode_errors::bigint;
        v_rtp_stream_data.rx_out_of_buffer_errors=v_rtp_stream.rx_out_of_buffer_errors::bigint;
        v_rtp_stream_data.rx_rtp_parse_errors=v_rtp_stream.rx_rtp_parse_errors::bigint;

        v_rtp_stream_data.rx_packet_delta_min=v_rtp_stream.rx_packet_delta_min;
        v_rtp_stream_data.rx_packet_delta_max=v_rtp_stream.rx_packet_delta_max;
        v_rtp_stream_data.rx_packet_delta_mean=v_rtp_stream.rx_packet_delta_mean;
        v_rtp_stream_data.rx_packet_delta_std=v_rtp_stream.rx_packet_delta_std;

        v_rtp_stream_data.rx_packet_jitter_min=v_rtp_stream.rx_packet_jitter_min;
        v_rtp_stream_data.rx_packet_jitter_max=v_rtp_stream.rx_packet_jitter_max;
        v_rtp_stream_data.rx_packet_jitter_mean=v_rtp_stream.rx_packet_jitter_mean;
        v_rtp_stream_data.rx_packet_jitter_std=v_rtp_stream.rx_packet_jitter_std;

        v_rtp_stream_data.rx_rtcp_jitter_min=v_rtp_stream.rx_rtcp_jitter_min;
        v_rtp_stream_data.rx_rtcp_jitter_max=v_rtp_stream.rx_rtcp_jitter_max;
        v_rtp_stream_data.rx_rtcp_jitter_mean=v_rtp_stream.rx_rtcp_jitter_mean;
        v_rtp_stream_data.rx_rtcp_jitter_std=v_rtp_stream.rx_rtcp_jitter_std;

        v_rtp_stream_data.tx_ssrc=v_rtp_stream.tx_ssrc::bigint;

        v_rtp_stream_data.tx_packets=v_rtp_stream.tx_packets::bigint;
        v_rtp_stream_data.tx_bytes=v_rtp_stream.tx_bytes::bigint;
        v_rtp_stream_data.tx_total_lost=v_rtp_stream.tx_total_lost::bigint;

        v_rtp_stream_data.tx_payloads_transcoded=v_rtp_stream.tx_payloads_transcoded;
        v_rtp_stream_data.tx_payloads_relayed=v_rtp_stream.tx_payloads_relayed;

        v_rtp_stream_data.tx_rtcp_jitter_min=v_rtp_stream.tx_rtcp_jitter_min;
        v_rtp_stream_data.tx_rtcp_jitter_max=v_rtp_stream.tx_rtcp_jitter_max;
        v_rtp_stream_data.tx_rtcp_jitter_mean=v_rtp_stream.tx_rtcp_jitter_mean;
        v_rtp_stream_data.tx_rtcp_jitter_std=v_rtp_stream.tx_rtcp_jitter_std;

        INSERT INTO rtp_statistics.streams VALUES( v_rtp_stream_data.*);
        perform event.rtp_statistics_insert_event(v_rtp_stream_data);
  end loop;

  v_cdr.global_tag=i_global_tag;

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

  perform stats.update_rt_stats(v_cdr);

  v_cdr.customer_price:=switch.customer_price_round(v_config, v_cdr.customer_price);
  v_cdr.vendor_price:=switch.vendor_price_round(v_config, v_cdr.vendor_price);

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

  -- generate event to billing engine
  perform event.billing_insert_event('cdr_full',v_billing_event);
  perform event.streaming_insert_event(v_cdr);
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
      DROP FUNCTION switch.writecdr(
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
    i_legb_local_tag character varying,
    i_msg_logger_path character varying,
    i_dump_level_id integer,
    i_audio_recorded boolean,
    i_rtp_stats_data json,
    i_rtp_statistics json,
    i_global_tag character varying,
    i_resources character varying,
    i_active_resources json,
    i_failed_resource_type_id smallint,
    i_failed_resource_id bigint,
    i_dtmf_events json,
    i_versions json,
    i_is_redirected boolean,
    i_dynamic json
);
      drop schema rtp_statistics cascade;
      alter table cdr.cdr drop column legb_local_tag;
      drop FUNCTION event.rtp_statistics_insert_event(ev_data anyelement);
      select pgq.drop_queue('rtp_statistics');

    }
  end
end
