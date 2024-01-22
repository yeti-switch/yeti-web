class AddRxSrtpDecryptErrorsCounter < ActiveRecord::Migration[7.0]
  def up
    execute %q{
      alter table rtp_statistics.tx_streams add rx_srtp_decrypt_errors bigint;
      alter type rtp_statistics.tx_stream_ty add attribute rx_srtp_decrypt_errors bigint;

CREATE or replace FUNCTION switch.write_rtp_statistics(i_data json, i_pop_id integer, i_node_id integer, i_lega_gateway_id bigint, i_lega_gateway_external_id bigint, i_legb_gateway_id bigint, i_legb_gateway_external_id bigint, i_lega_local_tag character varying, i_legb_local_tag character varying) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER COST 10
    AS $$
DECLARE
  v_rx rtp_statistics.rx_stream_ty;
  v_tx_stream rtp_statistics.tx_stream_ty;
  v_rtp_rx_stream_data rtp_statistics.rx_streams%rowtype;
  v_rtp_tx_stream_data rtp_statistics.tx_streams%rowtype;
BEGIN

  if i_data is null or json_array_length(i_data)=0 then
    return;
  end if;

  for v_tx_stream IN select * from json_populate_recordset(null::rtp_statistics.tx_stream_ty,i_data) LOOP

        if v_tx_stream.local_tag = i_lega_local_tag then
          -- legA stream
          v_rtp_tx_stream_data.gateway_id = i_lega_gateway_id;
          v_rtp_tx_stream_data.gateway_external_id = i_lega_gateway_external_id;
        elsif v_tx_stream.local_tag = i_legb_local_tag then
          -- legb stream
          v_rtp_tx_stream_data.gateway_id = i_legb_gateway_id;
          v_rtp_tx_stream_data.gateway_external_id = i_legb_gateway_external_id;
        else
          -- unknown stream
        end if;

        v_rtp_tx_stream_data.id=nextval('rtp_statistics.tx_streams_id_seq'::regclass);
        v_rtp_tx_stream_data.pop_id=i_pop_id;
        v_rtp_tx_stream_data.node_id=i_node_id;
        v_rtp_tx_stream_data.local_tag=v_tx_stream.local_tag;

        v_rtp_tx_stream_data.time_start=to_timestamp(v_tx_stream.time_start);
        v_rtp_tx_stream_data.time_end=to_timestamp(v_tx_stream.time_end);

        v_rtp_tx_stream_data.rtcp_rtt_min=v_tx_stream.rtcp_rtt_min;
        v_rtp_tx_stream_data.rtcp_rtt_max=v_tx_stream.rtcp_rtt_max;
        v_rtp_tx_stream_data.rtcp_rtt_mean=v_tx_stream.rtcp_rtt_mean;
        v_rtp_tx_stream_data.rtcp_rtt_std=v_tx_stream.rtcp_rtt_std;
        v_rtp_tx_stream_data.rx_out_of_buffer_errors=v_tx_stream.rx_out_of_buffer_errors;
        v_rtp_tx_stream_data.rx_rtp_parse_errors=v_tx_stream.rx_rtp_parse_errors;
        v_rtp_tx_stream_data.rx_dropped_packets=v_tx_stream.rx_dropped_packets;
        v_rtp_tx_stream_data.rx_srtp_decrypt_errors = v_tx_stream.rx_srtp_decrypt_errors;
        v_rtp_tx_stream_data.tx_packets=v_tx_stream.tx_packets;
        v_rtp_tx_stream_data.tx_bytes=v_tx_stream.tx_bytes;
        v_rtp_tx_stream_data.tx_ssrc=v_tx_stream.tx_ssrc;
        v_rtp_tx_stream_data.local_host=v_tx_stream.local_host;
        v_rtp_tx_stream_data.local_port=v_tx_stream.local_port;
        v_rtp_tx_stream_data.tx_total_lost=v_tx_stream.tx_total_lost;

        v_rtp_tx_stream_data.tx_payloads_transcoded=string_to_array(v_tx_stream.tx_payloads_transcoded,',');
        v_rtp_tx_stream_data.tx_payloads_relayed=string_to_array(v_tx_stream.tx_payloads_relayed,',');

        v_rtp_tx_stream_data.tx_rtcp_jitter_min=v_tx_stream.tx_rtcp_jitter_min;
        v_rtp_tx_stream_data.tx_rtcp_jitter_max=v_tx_stream.tx_rtcp_jitter_max;
        v_rtp_tx_stream_data.tx_rtcp_jitter_mean=v_tx_stream.tx_rtcp_jitter_mean;
        v_rtp_tx_stream_data.tx_rtcp_jitter_std=v_tx_stream.tx_rtcp_jitter_std;

        INSERT INTO rtp_statistics.tx_streams VALUES(v_rtp_tx_stream_data.*);
        PERFORM event.rtp_streams_insert_event('rtp_tx_stream', v_rtp_tx_stream_data);

        FOREACH v_rx IN ARRAY v_tx_stream.rx LOOP
          v_rtp_rx_stream_data = NULL;
          v_rtp_rx_stream_data.id=nextval('rtp_statistics.rx_streams_id_seq'::regclass);
          v_rtp_rx_stream_data.tx_stream_id = v_rtp_tx_stream_data.id;
          v_rtp_rx_stream_data.time_start = v_rtp_tx_stream_data.time_start;
          v_rtp_rx_stream_data.time_end = v_rtp_tx_stream_data.time_end;

          v_rtp_rx_stream_data.pop_id=v_rtp_tx_stream_data.pop_id;
          v_rtp_rx_stream_data.node_id=v_rtp_tx_stream_data.node_id;
          v_rtp_rx_stream_data.gateway_id=v_rtp_tx_stream_data.gateway_id;
          v_rtp_rx_stream_data.gateway_external_id=v_rtp_tx_stream_data.gateway_external_id;

          v_rtp_rx_stream_data.local_tag=v_tx_stream.local_tag;
          v_rtp_rx_stream_data.rx_ssrc=v_rx.rx_ssrc;

          -- local socket info from TX stream
          v_rtp_rx_stream_data.local_host = v_tx_stream.local_host;
          v_rtp_rx_stream_data.remote_port = v_tx_stream.local_port;

          v_rtp_rx_stream_data.remote_host=v_rx.remote_host;
          v_rtp_rx_stream_data.remote_port=v_rx.remote_port;
          v_rtp_rx_stream_data.rx_packets=v_rx.rx_packets;
          v_rtp_rx_stream_data.rx_bytes=v_rx.rx_bytes;
          v_rtp_rx_stream_data.rx_total_lost=v_rx.rx_total_lost;
          v_rtp_rx_stream_data.rx_payloads_transcoded=string_to_array(v_rx.rx_payloads_transcoded,',');
          v_rtp_rx_stream_data.rx_payloads_relayed=string_to_array(v_rx.rx_payloads_relayed,',');
          v_rtp_rx_stream_data.rx_decode_errors=v_rx.rx_decode_errors;
          v_rtp_rx_stream_data.rx_packet_delta_min=v_rx.rx_packet_delta_min;
          v_rtp_rx_stream_data.rx_packet_delta_max=v_rx.rx_packet_delta_max;
          v_rtp_rx_stream_data.rx_packet_delta_mean=v_rx.rx_packet_delta_mean;
          v_rtp_rx_stream_data.rx_packet_delta_std=v_rx.rx_packet_delta_std;
          v_rtp_rx_stream_data.rx_packet_jitter_min=v_rx.rx_packet_jitter_min;
          v_rtp_rx_stream_data.rx_packet_jitter_max=v_rx.rx_packet_jitter_max;
          v_rtp_rx_stream_data.rx_packet_jitter_mean=v_rx.rx_packet_jitter_mean;
          v_rtp_rx_stream_data.rx_packet_jitter_std=v_rx.rx_packet_jitter_std;
          v_rtp_rx_stream_data.rx_rtcp_jitter_min=v_rx.rx_rtcp_jitter_min;
          v_rtp_rx_stream_data.rx_rtcp_jitter_max=v_rx.rx_rtcp_jitter_max;
          v_rtp_rx_stream_data.rx_rtcp_jitter_mean=v_rx.rx_rtcp_jitter_mean;
          v_rtp_rx_stream_data.rx_rtcp_jitter_std=v_rx.rx_rtcp_jitter_std;

          INSERT INTO rtp_statistics.rx_streams VALUES(v_rtp_rx_stream_data.*);
          PERFORM event.rtp_streams_insert_event('rtp_rx_stream', v_rtp_rx_stream_data);
        END LOOP;
  end loop;

  RETURN;
END;
$$;


    }
  end

  def down
    execute %q{

CREATE or replace FUNCTION switch.write_rtp_statistics(i_data json, i_pop_id integer, i_node_id integer, i_lega_gateway_id bigint, i_lega_gateway_external_id bigint, i_legb_gateway_id bigint, i_legb_gateway_external_id bigint, i_lega_local_tag character varying, i_legb_local_tag character varying) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER COST 10
    AS $$
DECLARE
  v_rx rtp_statistics.rx_stream_ty;
  v_tx_stream rtp_statistics.tx_stream_ty;
  v_rtp_rx_stream_data rtp_statistics.rx_streams%rowtype;
  v_rtp_tx_stream_data rtp_statistics.tx_streams%rowtype;
BEGIN

  if i_data is null or json_array_length(i_data)=0 then
    return;
  end if;

  for v_tx_stream IN select * from json_populate_recordset(null::rtp_statistics.tx_stream_ty,i_data) LOOP

        if v_tx_stream.local_tag = i_lega_local_tag then
          -- legA stream
          v_rtp_tx_stream_data.gateway_id = i_lega_gateway_id;
          v_rtp_tx_stream_data.gateway_external_id = i_lega_gateway_external_id;
        elsif v_tx_stream.local_tag = i_legb_local_tag then
          -- legb stream
          v_rtp_tx_stream_data.gateway_id = i_legb_gateway_id;
          v_rtp_tx_stream_data.gateway_external_id = i_legb_gateway_external_id;
        else
          -- unknown stream
        end if;

        v_rtp_tx_stream_data.id=nextval('rtp_statistics.tx_streams_id_seq'::regclass);
        v_rtp_tx_stream_data.pop_id=i_pop_id;
        v_rtp_tx_stream_data.node_id=i_node_id;
        v_rtp_tx_stream_data.local_tag=v_tx_stream.local_tag;

        v_rtp_tx_stream_data.time_start=to_timestamp(v_tx_stream.time_start);
        v_rtp_tx_stream_data.time_end=to_timestamp(v_tx_stream.time_end);

        v_rtp_tx_stream_data.rtcp_rtt_min=v_tx_stream.rtcp_rtt_min;
        v_rtp_tx_stream_data.rtcp_rtt_max=v_tx_stream.rtcp_rtt_max;
        v_rtp_tx_stream_data.rtcp_rtt_mean=v_tx_stream.rtcp_rtt_mean;
        v_rtp_tx_stream_data.rtcp_rtt_std=v_tx_stream.rtcp_rtt_std;
        v_rtp_tx_stream_data.rx_out_of_buffer_errors=v_tx_stream.rx_out_of_buffer_errors;
        v_rtp_tx_stream_data.rx_rtp_parse_errors=v_tx_stream.rx_rtp_parse_errors;
        v_rtp_tx_stream_data.rx_dropped_packets=v_tx_stream.rx_dropped_packets;
        v_rtp_tx_stream_data.tx_packets=v_tx_stream.tx_packets;
        v_rtp_tx_stream_data.tx_bytes=v_tx_stream.tx_bytes;
        v_rtp_tx_stream_data.tx_ssrc=v_tx_stream.tx_ssrc;
        v_rtp_tx_stream_data.local_host=v_tx_stream.local_host;
        v_rtp_tx_stream_data.local_port=v_tx_stream.local_port;
        v_rtp_tx_stream_data.tx_total_lost=v_tx_stream.tx_total_lost;

        v_rtp_tx_stream_data.tx_payloads_transcoded=string_to_array(v_tx_stream.tx_payloads_transcoded,',');
        v_rtp_tx_stream_data.tx_payloads_relayed=string_to_array(v_tx_stream.tx_payloads_relayed,',');

        v_rtp_tx_stream_data.tx_rtcp_jitter_min=v_tx_stream.tx_rtcp_jitter_min;
        v_rtp_tx_stream_data.tx_rtcp_jitter_max=v_tx_stream.tx_rtcp_jitter_max;
        v_rtp_tx_stream_data.tx_rtcp_jitter_mean=v_tx_stream.tx_rtcp_jitter_mean;
        v_rtp_tx_stream_data.tx_rtcp_jitter_std=v_tx_stream.tx_rtcp_jitter_std;

        INSERT INTO rtp_statistics.tx_streams VALUES(v_rtp_tx_stream_data.*);
        PERFORM event.rtp_streams_insert_event('rtp_tx_stream', v_rtp_tx_stream_data);

        FOREACH v_rx IN ARRAY v_tx_stream.rx LOOP
          v_rtp_rx_stream_data = NULL;
          v_rtp_rx_stream_data.id=nextval('rtp_statistics.rx_streams_id_seq'::regclass);
          v_rtp_rx_stream_data.tx_stream_id = v_rtp_tx_stream_data.id;
          v_rtp_rx_stream_data.time_start = v_rtp_tx_stream_data.time_start;
          v_rtp_rx_stream_data.time_end = v_rtp_tx_stream_data.time_end;

          v_rtp_rx_stream_data.pop_id=v_rtp_tx_stream_data.pop_id;
          v_rtp_rx_stream_data.node_id=v_rtp_tx_stream_data.node_id;
          v_rtp_rx_stream_data.gateway_id=v_rtp_tx_stream_data.gateway_id;
          v_rtp_rx_stream_data.gateway_external_id=v_rtp_tx_stream_data.gateway_external_id;

          v_rtp_rx_stream_data.local_tag=v_tx_stream.local_tag;
          v_rtp_rx_stream_data.rx_ssrc=v_rx.rx_ssrc;

          -- local socket info from TX stream
          v_rtp_rx_stream_data.local_host = v_tx_stream.local_host;
          v_rtp_rx_stream_data.remote_port = v_tx_stream.local_port;

          v_rtp_rx_stream_data.remote_host=v_rx.remote_host;
          v_rtp_rx_stream_data.remote_port=v_rx.remote_port;
          v_rtp_rx_stream_data.rx_packets=v_rx.rx_packets;
          v_rtp_rx_stream_data.rx_bytes=v_rx.rx_bytes;
          v_rtp_rx_stream_data.rx_total_lost=v_rx.rx_total_lost;
          v_rtp_rx_stream_data.rx_payloads_transcoded=string_to_array(v_rx.rx_payloads_transcoded,',');
          v_rtp_rx_stream_data.rx_payloads_relayed=string_to_array(v_rx.rx_payloads_relayed,',');
          v_rtp_rx_stream_data.rx_decode_errors=v_rx.rx_decode_errors;
          v_rtp_rx_stream_data.rx_packet_delta_min=v_rx.rx_packet_delta_min;
          v_rtp_rx_stream_data.rx_packet_delta_max=v_rx.rx_packet_delta_max;
          v_rtp_rx_stream_data.rx_packet_delta_mean=v_rx.rx_packet_delta_mean;
          v_rtp_rx_stream_data.rx_packet_delta_std=v_rx.rx_packet_delta_std;
          v_rtp_rx_stream_data.rx_packet_jitter_min=v_rx.rx_packet_jitter_min;
          v_rtp_rx_stream_data.rx_packet_jitter_max=v_rx.rx_packet_jitter_max;
          v_rtp_rx_stream_data.rx_packet_jitter_mean=v_rx.rx_packet_jitter_mean;
          v_rtp_rx_stream_data.rx_packet_jitter_std=v_rx.rx_packet_jitter_std;
          v_rtp_rx_stream_data.rx_rtcp_jitter_min=v_rx.rx_rtcp_jitter_min;
          v_rtp_rx_stream_data.rx_rtcp_jitter_max=v_rx.rx_rtcp_jitter_max;
          v_rtp_rx_stream_data.rx_rtcp_jitter_mean=v_rx.rx_rtcp_jitter_mean;
          v_rtp_rx_stream_data.rx_rtcp_jitter_std=v_rx.rx_rtcp_jitter_std;

          INSERT INTO rtp_statistics.rx_streams VALUES(v_rtp_rx_stream_data.*);
          PERFORM event.rtp_streams_insert_event('rtp_rx_stream', v_rtp_rx_stream_data);
        END LOOP;
  end loop;

  RETURN;
END;
$$;


      alter table rtp_statistics.tx_streams drop column rx_srtp_decrypt_errors;
      alter type rtp_statistics.tx_stream_ty drop attribute rx_srtp_decrypt_errors;

    }
  end
end
