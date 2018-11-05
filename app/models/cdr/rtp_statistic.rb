# == Schema Information
#
# Table name: rtp_statistics.streams
#
#  id                  :integer          not null, primary key
#  local_tag           :string           not null
#  pop_id              :integer          not null
#  node_id             :integer          not null
#  gateway_id          :integer          not null
#  gateway_external_id :integer
#  remote_jitter_var   :float
#  remote_jitter_max   :float
#  remote_jitter_mean  :float
#  remote_jitter_min   :float
#  local_jitter_var    :float
#  local_jitter_max    :float
#  local_jitter_mean   :float
#  local_jitter_min    :float
#  rtcp_jitter_var     :float
#  rtcp_jitter_max     :float
#  rtcp_jitter_mean    :float
#  rtcp_jitter_min     :float
#  local_rtt_var       :float
#  local_rtt_max       :float
#  local_rtt_mean      :float
#  local_rtt_min       :float
#  local_delta_var     :float
#  local_delta_max     :float
#  local_delta_mean    :float
#  local_delta_min     :float
#

class Cdr::RtpStatistic < Cdr::Base

  self.table_name = 'rtp_statistics.streams'

  belongs_to :gateway, class_name: 'Gateway', foreign_key: :gateway_id
  belongs_to :pop, class_name: 'Pop', foreign_key: :pop_id
  belongs_to :node, class_name: 'Node', foreign_key: :node_id

  def display_name
    "#{self.id}"
  end

end
