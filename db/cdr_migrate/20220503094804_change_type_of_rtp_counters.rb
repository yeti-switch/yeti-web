class ChangeTypeOfRtpCounters < ActiveRecord::Migration[6.1]
  def up
    execute %q{

alter table rtp_statistics.tx_streams
  alter column rx_out_of_buffer_errors type bigint,
  alter column rx_rtp_parse_errors type bigint,
  alter column rx_dropped_packets type bigint,
  alter column tx_packets type bigint,
  alter column tx_bytes type bigint;

alter table rtp_statistics.rx_streams
  alter column rx_packets type bigint,
  alter column rx_bytes type bigint,
  alter column rx_total_lost type bigint,
  alter column rx_decode_errors type bigint;


/*
CREATE INDEX rx_streams_local_tag_idx ON ONLY rtp_statistics.rx_streams USING btree (local_tag);
CREATE INDEX rx_streams_tx_stream_id_idx ON ONLY rtp_statistics.rx_streams USING btree (tx_stream_id);
CREATE INDEX tx_streams_local_tag_idx ON ONLY rtp_statistics.tx_streams USING btree (local_tag);
*/

drop type rtp_statistics.tx_stream_ty;
drop type rtp_statistics.rx_stream_ty;

create type rtp_statistics.rx_stream_ty as(
  rx_ssrc bigint,
  local_host inet,
  local_port integer,
  remote_host inet,
  remote_port integer,
  rx_packets bigint,
  rx_bytes bigint,
  rx_total_lost bigint,
  rx_payloads_transcoded varchar,
  rx_payloads_relayed varchar,
  rx_decode_errors bigint,
  rx_packet_delta_min real,
  rx_packet_delta_max real,
  rx_packet_delta_mean real,
  rx_packet_delta_std real,
  rx_packet_jitter_min real,
  rx_packet_jitter_max real,
  rx_packet_jitter_mean real,
  rx_packet_jitter_std real,
  rx_rtcp_jitter_min real,
  rx_rtcp_jitter_max real,
  rx_rtcp_jitter_mean real,
  rx_rtcp_jitter_std real
);

create type rtp_statistics.tx_stream_ty as(
  time_start double precision,
  time_end double precision,
  local_tag varchar,
  rtcp_rtt_min real,
  rtcp_rtt_max real,
  rtcp_rtt_mean real,
  rtcp_rtt_std real,
  rx_out_of_buffer_errors bigint,
  rx_rtp_parse_errors bigint,
  rx_dropped_packets bigint,
  tx_packets bigint,
  tx_bytes bigint,
  tx_ssrc bigint,
  local_host inet,
  local_port integer,
  tx_total_lost integer,

  tx_payloads_transcoded varchar,
  tx_payloads_relayed varchar,

  tx_rtcp_jitter_min real,
  tx_rtcp_jitter_max real,
  tx_rtcp_jitter_mean real,
  tx_rtcp_jitter_std real,
  rx rtp_statistics.rx_stream_ty[]
);

            }
  end

  def down

    execute %q{

alter table rtp_statistics.tx_streams
  alter column rx_out_of_buffer_errors type integer,
  alter column rx_rtp_parse_errors type integer,
  alter column rx_dropped_packets type integer,
  alter column tx_packets type integer,
  alter column tx_bytes type integer;

alter table rtp_statistics.rx_streams
  alter column rx_packets type integer,
  alter column rx_bytes type integer,
  alter column rx_total_lost type integer,
  alter column rx_decode_errors type integer;

drop type rtp_statistics.tx_stream_ty;
drop type rtp_statistics.rx_stream_ty;

create type rtp_statistics.rx_stream_ty as(
  rx_ssrc bigint,
  local_host inet,
  local_port integer,
  remote_host inet,
  remote_port integer,
  rx_packets integer,
  rx_bytes integer,
  rx_total_lost integer,
  rx_payloads_transcoded varchar,
  rx_payloads_relayed varchar,
  rx_decode_errors integer,
  rx_packet_delta_min real,
  rx_packet_delta_max real,
  rx_packet_delta_mean real,
  rx_packet_delta_std real,
  rx_packet_jitter_min real,
  rx_packet_jitter_max real,
  rx_packet_jitter_mean real,
  rx_packet_jitter_std real,
  rx_rtcp_jitter_min real,
  rx_rtcp_jitter_max real,
  rx_rtcp_jitter_mean real,
  rx_rtcp_jitter_std real
);

create type rtp_statistics.tx_stream_ty as(
  time_start double precision,
  time_end double precision,
  local_tag varchar,
  rtcp_rtt_min real,
  rtcp_rtt_max real,
  rtcp_rtt_mean real,
  rtcp_rtt_std real,
  rx_out_of_buffer_errors integer,
  rx_rtp_parse_errors integer,
  rx_dropped_packets integer,
  tx_packets  integer,
  tx_bytes  integer,
  tx_ssrc bigint,
  local_host inet,
  local_port integer,
  tx_total_lost integer,

  tx_payloads_transcoded varchar,
  tx_payloads_relayed varchar,

  tx_rtcp_jitter_min real,
  tx_rtcp_jitter_max real,
  tx_rtcp_jitter_mean real,
  tx_rtcp_jitter_std real,
  rx rtp_statistics.rx_stream_ty[]
);

DROP INDEX rtp_statistics.rx_streams_local_tag_idx;
DROP INDEX rtp_statistics.rx_streams_tx_stream_id_idx;
DROP INDEX rtp_statistics.tx_streams_local_tag_idx;

}



  end
end
