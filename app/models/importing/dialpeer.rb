# == Schema Information
#
# Table name: import_dialpeers
#
#  id                  :integer          not null, primary key
#  o_id                :integer
#  enabled             :boolean
#  prefix              :string
#  src_rewrite_rule    :string
#  dst_rewrite_rule    :string
#  gateway_id          :integer
#  gateway_name        :string
#  routing_group_id    :integer
#  routing_group_name  :string
#  connect_fee         :decimal(, )
#  vendor_id           :integer
#  vendor_name         :string
#  account_id          :integer
#  account_name        :string
#  src_rewrite_result  :string
#  dst_rewrite_result  :string
#  locked              :boolean
#  priority            :integer
#  asr_limit           :float
#  acd_limit           :float
#  initial_interval    :integer
#  next_interval       :integer
#  initial_rate        :decimal(, )
#  next_rate           :decimal(, )
#  lcr_rate_multiplier :decimal(, )
#  capacity            :integer
#  valid_from          :datetime
#  valid_till          :datetime
#  gateway_group_name  :string
#  gateway_group_id    :integer
#  error_string        :string
#  force_hit_rate      :float
#  short_calls_limit   :float            default("1"), not null
#  exclusive_route     :boolean
#  routing_tag_id      :integer
#  routing_tag_name    :string
#  reverse_billing     :boolean
#  routing_tag_ids     :integer          default("{}"), not null, is an Array
#

class Importing::Dialpeer < Importing::Base
  self.table_name = 'import_dialpeers'


  belongs_to :gateway, class_name: '::Gateway'
  belongs_to :gateway_group, class_name: '::GatewayGroup'
  belongs_to :routing_group, class_name: '::RoutingGroup'
  belongs_to :routing_tag, class_name: Routing::RoutingTag, foreign_key: :routing_tag_id
  belongs_to :account, class_name: '::Account'
  belongs_to :vendor, -> { where vendor: true }, class_name: '::Contractor'
  has_many :dialpeer_next_rates, dependent: :destroy

  self.import_attributes = ['prefix', 'enabled', 'lcr_rate_multiplier',
                            'initial_interval', 'next_interval', 'initial_rate', 'next_rate', 'connect_fee', 'reverse_billing',
                            'gateway_id', 'gateway_group_id', 'routing_group_id',
                            'vendor_id', 'account_id', 'src_rewrite_rule', 'src_rewrite_result',
                            'dst_rewrite_rule', 'dst_rewrite_result', 'asr_limit', 'acd_limit', 'short_calls_limit', 'priority', 'capacity',
                            'valid_from', 'valid_till', 'force_hit_rate']
  self.import_class = ::Dialpeer

  def self.after_import_hook(unique_columns = [])
    self.where(asr_limit: nil).update_all(asr_limit: 0)
    super
  end

end
