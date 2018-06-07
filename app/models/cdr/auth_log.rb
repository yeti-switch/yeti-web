# == Schema Information
#
# Table name: auth_log.auth_log
#
#  id                    :integer          not null, primary key
#  node_id               :integer
#  pop_id                :integer
#  request_time          :datetime         not null
#  transport_proto_id    :integer
#  transport_remote_ip   :string
#  transport_remote_port :integer
#  transport_local_ip    :string
#  transport_local_port  :integer
#  origination_ip        :string
#  origination_port      :integer
#  origination_proto_id  :integer
#  method                :string
#  ruri                  :string
#  from_uri              :string
#  to_uri                :string
#  call_id               :string
#  success               :boolean
#  code                  :integer
#  reason                :string
#  internal_reason       :string
#  nonce                 :string
#  response              :string
#  gateway_id            :integer
#  x_yeti_auth           :string
#  diversion             :string
#  pai                   :string
#  ppi                   :string
#  privacy               :string
#  rpid                  :string
#  rpid_privacy          :string
#

class Cdr::AuthLog < Cdr::Base

  self.table_name = 'auth_log.auth_log'

  belongs_to :gateway, class_name: 'Gateway', foreign_key: :gateaway_id
  belongs_to :node, class_name: 'Node', foreign_key: :node_id
  belongs_to :pop, class_name: 'Pop', foreign_key: :pop_id

  belongs_to :origination_protocol, class_name: 'Equipment::TransportProtocol', foreign_key: :origination_proto_id
  belongs_to :transport_protocol, class_name: 'Equipment::TransportProtocol', foreign_key: :transport_proto_id


  scope :successful, -> { where success: true }
  scope :failed, -> { where success: false }

  def display_name
    "#{self.id}"
  end

end
