ActiveAdmin.register Cdr::RtpStatistic, as: 'RtpStatistics' do
  menu parent: "CDR", label: "RTP Statistics", priority: 96

  actions :index, :show
  config.batch_actions = false
  config.sort_order = 'id_desc'

  def scoped_collection
      super.preload( :pop, :node, :gateway)
  end

  index do
    id_column
    column :local_tag
    column :time_start
    column :time_end
    column :pop
    column :node
    column :gateway
    column :gateway_external_id

    column :rtcp_rtt_min
    column :rtcp_rtt_max
    column :rtcp_rtt_mean
    column :rtcp_rtt_std
    column :rx_rtcp_rr_count
    column :rx_rtcp_sr_count

    column :tx_rtcp_rr_count
    column :tx_rtcp_sr_count
    column :rx_ssrc do |c|
      "0x#{c.rx_ssrc.to_s(16).upcase}" ## to HEX
    end
    column :local_host
    column :local_port
    column :remote_host
    column :remote_port

    column :rx_packets
    column :rx_bytes
    column :rx_total_lost
    column :rx_payloads_transcoded
    column :rx_payloads_relayed
    column :rx_decode_errors
    column :rx_out_of_buffer_errors
    column :rx_rtp_parse_errors
    column :rx_packet_delta_min
    column :rx_packet_delta_max
    column :rx_packet_delta_mean
    column :rx_packet_delta_std
    column :rx_packet_jitter_min
    column :rx_packet_jitter_max
    column :rx_packet_jitter_mean
    column :rx_packet_jitter_std
    column :rx_rtcp_jitter_min
    column :rx_rtcp_jitter_max
    column :rx_rtcp_jitter_mean
    column :rx_rtcp_jitter_std

    column :tx_ssrc do |c|
      "0x#{c.tx_ssrc.to_s(16).upcase}" ## to HEX
    end
    column :tx_packets
    column :tx_bytes
    column :tx_total_lost
    column :tx_payloads_transcoded
    column :tx_payloads_relayed
    column :tx_rtcp_jitter_min
    column :tx_rtcp_jitter_max
    column :tx_rtcp_jitter_mean
    column :tx_rtcp_jitter_std
  end

  filter :id
  filter :local_tag
  filter :pop
  filter :node
  filter :gateway
  filter :gateway_external_id
  
  show do
    attributes_table do
      row :id
      row :local_tag
      row :time_start
      row :time_end
      row :pop
      row :node
      row :gateway
      row :gateway_external_id

      row :rtcp_rtt_min
      row :rtcp_rtt_max
      row :rtcp_rtt_mean
      row :rtcp_rtt_std
      row :rx_rtcp_rr_count
      row :rx_rtcp_sr_count

      row :tx_rtcp_rr_count
      row :tx_rtcp_sr_count
      row :rx_ssrc do |c|
        "0x#{c.rx_ssrc.to_s(16).upcase}" ## to HEX
      end
      row :local_host
      row :local_port
      row :remote_host
      row :remote_port

      row :rx_packets
      row :rx_bytes
      row :rx_total_lost
      row :rx_payloads_transcoded
      row :rx_payloads_relayed
      row :rx_decode_errors
      row :rx_out_of_buffer_errors
      row :rx_rtp_parse_errors
      row :rx_packet_delta_min
      row :rx_packet_delta_max
      row :rx_packet_delta_mean
      row :rx_packet_delta_std
      row :rx_packet_jitter_min
      row :rx_packet_jitter_max
      row :rx_packet_jitter_mean
      row :rx_packet_jitter_std
      row :rx_rtcp_jitter_min
      row :rx_rtcp_jitter_max
      row :rx_rtcp_jitter_mean
      row :rx_rtcp_jitter_std

      row :tx_ssrc do |c|
        "0x#{c.tx_ssrc.to_s(16).upcase}" ## to HEX
      end
      row :tx_packets
      row :tx_bytes
      row :tx_total_lost
      row :tx_payloads_transcoded
      row :tx_payloads_relayed
      row :tx_rtcp_jitter_min
      row :tx_rtcp_jitter_max
      row :tx_rtcp_jitter_mean
      row :tx_rtcp_jitter_std
      
    end
  end

end
