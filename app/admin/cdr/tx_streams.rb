# frozen_string_literal: true

ActiveAdmin.register RtpStatistics::TxStream, as: 'RtpTxStreams' do
  menu parent: 'CDR', label: 'RTP TX Streams', priority: 96

  actions :index, :show
  config.batch_actions = false
  config.sort_order = 'id_desc'

  acts_as_export :id,
                 :time_start,
                 :time_end,
                 [:gateway_name, proc { |row| row.gateway.try(:name) }],
                 :gateway_external_id,
                 [:node_name, proc { |row| row.node.try(:name) }],
                 [:pop_name, proc { |row| row.pop.try(:name) }],
                 :local_tag,
                 :rtcp_rtt_min,
                 :rtcp_rtt_max,
                 :rtcp_rtt_mean,
                 :rtcp_rtt_std,
                 :rx_out_of_buffer_errors,
                 :rx_rtp_parse_errors,
                 :rx_dropped_packets,
                 :tx_packets,
                 :tx_bytes,
                 :tx_ssrc,
                 :local_host,
                 :local_port,
                 :tx_total_lost,
                 :tx_payloads_transcoded,
                 :tx_payloads_relayed,
                 :tx_rtcp_jitter_min,
                 :tx_rtcp_jitter_max,
                 :tx_rtcp_jitter_mean,
                 :tx_rtcp_jitter_std

  with_default_params do
    params[:q] = { time_start_gteq_datetime_picker: 0.days.ago.beginning_of_day }
    'Only RTP streams started from beginning of the day showed by default'
  end

  controller do
    def scoped_collection
      super.preload(:pop, :node, :gateway)
    end
  end

  scope :all, show_count: false
  scope :no_tx, show_count: false

  filter :id
  filter :time_start, as: :date_time_range
  filter :time_end, as: :date_time_range
  filter :pop
  filter :node
  filter :gateway,
         input_html: { class: 'chosen-ajax', 'data-path': '/gateways/search' },
         collection: proc {
           resource_id = params.fetch(:q, {})[:gateway_id_eq]
           resource_id ? Gateway.where(id: resource_id) : []
         }

  filter :gateway_external_id
  filter :local_tag
  filter :local_host
  filter :local_port
  filter :tx_ssrc, as: :numeric, filters: %i[hex equals]
  filter :tx_packets
  filter :tx_bytes
  filter :rtcp_rtt_min
  filter :rtcp_rtt_max
  filter :rtcp_rtt_mean
  filter :rtcp_rtt_std
  filter :rx_out_of_buffer_errors
  filter :rx_rtp_parse_errors
  filter :rx_dropped_packets
  filter :tx_total_lost
  filter :tx_rtcp_jitter_min
  filter :tx_rtcp_jitter_max
  filter :tx_rtcp_jitter_mean
  filter :tx_rtcp_jitter_std

  index do
    id_column
    column :time_start
    column :time_end
    column :pop
    column :node
    column :gateway
    column :gateway_external_id
    column :local_tag
    column :rtcp_rtt_min
    column :rtcp_rtt_max
    column :rtcp_rtt_mean
    column :rtcp_rtt_std
    column :rx_out_of_buffer_errors
    column :rx_rtp_parse_errors
    column :rx_dropped_packets
    column :tx_packets
    column :tx_bytes
    column :tx_ssrc do |c|
      c.tx_ssrc.nil? ? '' : "0x#{c.tx_ssrc.to_s(16).upcase}" ## to HEX
    end
    column :local_host
    column :local_port
    column :tx_total_lost
    column :tx_payloads_transcoded
    column :tx_payloads_relayed
    column :tx_rtcp_jitter_min
    column :tx_rtcp_jitter_max
    column :tx_rtcp_jitter_mean
    column :tx_rtcp_jitter_std
  end

  show do
    attributes_table do
      row :id
      row :time_start
      row :time_end
      row :pop
      row :node
      row :gateway
      row :local_tag
      row :rtcp_rtt_min
      row :rtcp_rtt_max
      row :rtcp_rtt_mean
      row :rtcp_rtt_std
      row :rx_out_of_buffer_errors
      row :rx_rtp_parse_errors
      row :rx_dropped_packets
      row :tx_packets
      row :tx_bytes
      row :tx_ssrc do |c|
        c.tx_ssrc.nil? ? '' : "0x#{c.tx_ssrc.to_s(16).upcase}" ## to HEX
      end
      row :local_host
      row :local_port
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
