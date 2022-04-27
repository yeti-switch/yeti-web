# frozen_string_literal: true

ActiveAdmin.register RtpStatistics::RxStream, as: 'RtpRxStreams' do
  menu parent: 'CDR', label: 'RTP RX Streams', priority: 96

  actions :index, :show
  config.batch_actions = false
  config.sort_order = 'id_desc'

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
  scope :no_rx, show_count: false

  index do
    id_column
    #column :tx_stream_id
    #
    column :local_tag

    column :time_start
    column :time_end
    column :pop
    column :node
    column :gateway
    column :gateway_external_id

    column :rx_ssrc do |c|
      c.rx_ssrc.nil? ? '' : "0x#{c.rx_ssrc.to_s(16).upcase}" ## to HEX
    end

    column :remote_host
    column :remote_port
    column :rx_packets
    column :rx_bytes
    column :rx_total_lost
    column :rx_payloads_transcoded
    column :rx_payloads_relayed
    column :rx_decode_errors
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

  end

  filter :id
  filter :time_start, as: :date_time_range
  filter :time_end, as: :date_time_range
  filter :local_tag
  filter :pop
  filter :node
  filter :gateway,
         input_html: { class: 'chosen-ajax', 'data-path': '/gateways/search' },
         collection: proc {
           resource_id = params.fetch(:q, {})[:gateway_id_eq]
           resource_id ? Gateway.where(id: resource_id) : []
         }

  filter :gateway_external_id
  filter :remote_host
  filter :remote_port
  filter :rx_packets
  filter :rx_bytes
  filter :rx_ssrc, as: :numeric, filters: %i[hex equals]

  show do
    attributes_table do
      row :id
      row :tx_stream_id
      row :local_tag
      row :time_start
      row :time_end
      row :pop
      row :node
      row :gateway
      row :gateway_external_id
      row :rx_ssrc do |c|
        c.rx_ssrc.nil? ? '' : "0x#{c.rx_ssrc.to_s(16).upcase}" ## to HEX
      end
      row :remote_host
      row :remote_port
      row :rx_packets
      row :rx_bytes
      row :rx_total_lost
      row :rx_payloads_transcoded
      row :rx_payloads_relayed
      row :rx_decode_errors
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
    end
  end
end
