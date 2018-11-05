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
    column :pop
    column :node
    column :gateway
    column :gateway_external_id
    column :remote_jitter_var
    column :remote_jitter_max
    column :remote_jitter_mean
    column :remote_jitter_min
    column :local_jitter_var
    column :local_jitter_max
    column :local_jitter_mean
    column :local_jitter_min
    column :rtcp_jitter_var
    column :rtcp_jitter_max
    column :rtcp_jitter_mean
    column :rtcp_jitter_min
    column :local_rtt_var
    column :local_rtt_max
    column :local_rtt_mean
    column :local_rtt_min
    column :local_delta_var
    column :local_delta_max
    column :local_delta_mean
    column :local_delta_min
  end

  filter :id
  filter :local_tag
  filter :pop
  filter :node
  filter :gateway
  filter :gateway_external_id
  filter :remote_jitter_var
  filter :remote_jitter_max
  filter :remote_jitter_mean
  filter :remote_jitter_min
  filter :local_jitter_var
  filter :local_jitter_max
  filter :local_jitter_mean
  filter :local_jitter_min
  filter :rtcp_jitter_var
  filter :rtcp_jitter_max
  filter :rtcp_jitter_mean
  filter :rtcp_jitter_min
  filter :local_rtt_var
  filter :local_rtt_max
  filter :local_rtt_mean
  filter :local_rtt_min
  filter :local_delta_var
  filter :local_delta_max
  filter :local_delta_mean
  filter :local_delta_min

end
