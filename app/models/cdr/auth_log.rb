# == Schema Information
#
# Table name: auth_log.auth_log
#
#  id                   :integer          not null, primary key
#  node_id              :integer
#  pop_id               :integer
#  request_time         :datetime         not null
#  sign_orig_ip         :string
#  sign_orig_port       :integer
#  sign_orig_local_ip   :string
#  sign_orig_local_port :integer
#  auth_orig_ip         :string
#  auth_orig_port       :integer
#  ruri                 :string
#  from_uri             :string
#  to_uri               :string
#  orig_call_id         :string
#  success              :boolean          default(FALSE), not null
#  code                 :integer
#  reason               :string
#  internal_reason      :string
#  nonce                :string
#  response             :string
#  gateway_id           :integer
#

class Cdr::AuthLog < Cdr::Base

  self.table_name = 'auth_log.auth_log'

  belongs_to :gateway, class_name: 'Gateway', foreign_key: :gateaway_id
  belongs_to :node, class_name: 'Node', foreign_key: :node_id
  belongs_to :pop, class_name: 'Pop', foreign_key: :pop_id


  def display_name
    "#{self.id}"
  end

end
