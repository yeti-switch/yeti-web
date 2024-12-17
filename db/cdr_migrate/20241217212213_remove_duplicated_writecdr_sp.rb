class RemoveDuplicatedWritecdrSp < ActiveRecord::Migration[7.0]

  def up
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
i_legb_ruri character varying,
i_legb_outbound_proxy character varying,
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
i_dump_level_id smallint,
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
i_dynamic json,
i_lega_request_headers json,
i_legb_request_headers json,
i_legb_reply_headers json,
i_lega_identity json
);

}
  end

  def down
    execute %q{

CREATE or replace FUNCTION switch.writecdr(
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
i_legb_ruri character varying,
i_legb_outbound_proxy character varying,
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
i_dump_level_id smallint,
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
i_dynamic json,
i_lega_request_headers json,
i_legb_request_headers json,
i_legb_reply_headers json,
i_lega_identity json
) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER COST 10
    AS $$
BEGIN
  RETURN switch.writecdr(
i_is_master, i_node_id, i_pop_id, i_routing_attempt, i_is_last_cdr,
i_lega_transport_protocol_id, i_lega_local_ip, i_lega_local_port, i_lega_remote_ip,
i_lega_remote_port, i_legb_transport_protocol_id,
i_legb_local_ip, i_legb_local_port, i_legb_remote_ip, i_legb_remote_port, i_legb_ruri,
i_legb_outbound_proxy, i_time_data, i_early_media_present, i_legb_disconnect_code, i_legb_disconnect_reason,
i_disconnect_initiator, i_internal_disconnect_code, i_internal_disconnect_reason, i_lega_disconnect_code, i_lega_disconnect_reason,
NULL, /* i_internal_disconnect_code_id */
i_orig_call_id, i_term_call_id, i_local_tag, i_legb_local_tag, i_msg_logger_path,
i_dump_level_id, i_audio_recorded, i_rtp_stats_data, i_rtp_statistics,
i_global_tag, i_resources, i_active_resources, i_failed_resource_type_id, i_failed_resource_id,
i_dtmf_events, i_versions, i_is_redirected, i_dynamic,
i_lega_request_headers,
i_legb_request_headers,
i_legb_reply_headers,
i_lega_identity
);

END;
$$;

}
  end


end


