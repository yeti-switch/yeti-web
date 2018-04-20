# == Schema Information
#
# Table name: data_import.import_customers_auth
#
#  id                               :integer          not null, primary key
#  o_id                             :integer
#  customer_name                    :string
#  customer_id                      :integer
#  routing_group_name               :string
#  routing_group_id                 :integer
#  rateplan_name                    :string
#  rateplan_id                      :integer
#  enabled                          :boolean
#  account_name                     :string
#  account_id                       :integer
#  gateway_name                     :string
#  gateway_id                       :integer
#  src_rewrite_rule                 :string
#  src_rewrite_result               :string
#  dst_rewrite_rule                 :string
#  dst_rewrite_result               :string
#  src_prefix                       :string
#  dst_prefix                       :string
#  x_yeti_auth                      :string
#  name                             :string
#  dump_level_id                    :integer
#  dump_level_name                  :string
#  capacity                         :integer
#  ip                               :string
#  uri_domain                       :string
#  pop_name                         :string
#  pop_id                           :integer
#  diversion_policy_id              :integer
#  diversion_policy_name            :string
#  diversion_rewrite_result         :string
#  diversion_rewrite_rule           :string
#  src_name_rewrite_result          :string
#  src_name_rewrite_rule            :string
#  error_string                     :string
#  dst_numberlist_id                :integer
#  dst_numberlist_name              :string
#  src_numberlist_id                :integer
#  src_numberlist_name              :string
#  allow_receive_rate_limit         :boolean          default(FALSE), not null
#  send_billing_information         :boolean          default(FALSE), not null
#  routing_plan_id                  :integer
#  routing_plan_name                :string
#  radius_auth_profile_id           :integer
#  radius_auth_profile_name         :string
#  radius_accounting_profile_id     :integer
#  radius_accounting_profile_name   :string
#  src_number_radius_rewrite_rule   :string
#  src_number_radius_rewrite_result :string
#  dst_number_radius_rewrite_rule   :string
#  dst_number_radius_rewrite_result :string
#  enable_audio_recording           :boolean
#  from_domain                      :string
#  to_domain                        :string
#  transport_protocol_id            :integer
#  transport_protocol_name          :string
#  min_dst_number_length            :integer
#  max_dst_number_length            :integer
#  check_account_balance            :boolean
#  require_incoming_auth            :boolean
#  tag_action_id                    :integer
#  tag_action_value                 :integer          default([]), not null, is an Array
#  tag_action_name                  :string
#  tag_action_value_names           :string
#  dst_number_min_length            :integer
#  dst_number_max_length            :integer
#  reject_calls                     :boolean
#

class Importing::CustomersAuth < Importing::Base
  self.table_name = 'data_import.import_customers_auth'
  attr_accessor :file

  belongs_to :gateway, class_name: '::Gateway'
  belongs_to :account, class_name: '::Account'
  belongs_to :routing_plan, class_name: '::Routing::RoutingPlan', foreign_key: :routing_plan_id
  belongs_to :rateplan, class_name: '::Rateplan'
  belongs_to :pop, class_name: '::Pop'
  belongs_to :customer, -> {where customer: true}, class_name: '::Contractor', foreign_key: :customer_id
  belongs_to :diversion_policy, class_name: '::DiversionPolicy'
  belongs_to :dump_level, class_name: '::DumpLevel'

  belongs_to :dst_numberlist, class_name: '::Routing::Numberlist', foreign_key: :dst_numberlist_id
  belongs_to :src_numberlist, class_name: '::Routing::Numberlist', foreign_key: :src_numberlist_id
  belongs_to :radius_auth_profile, class_name: '::Equipment::Radius::AuthProfile', foreign_key: :radius_auth_profile_id
  belongs_to :radius_accounting_profile, class_name: '::Equipment::Radius::AccountingProfile', foreign_key: :radius_accounting_profile_id
  belongs_to :transport_protocol, class_name: Equipment::TransportProtocol, foreign_key: :transport_protocol_id
  belongs_to :tag_action, class_name: 'Routing::TagAction'


  self.import_attributes = [
      'enabled',
      'reject_calls',
      'name',
      'ip',
      'pop_id',
      'src_prefix',
      'dst_prefix',
      'uri_domain',
      'from_domain',
      'to_domain',
      'x_yeti_auth',
      'customer_id',
      'account_id',
      'check_account_balance',
      'gateway_id',
      'rateplan_id',
      'routing_plan_id',
      'dst_numberlist_id',
      'src_numberlist_id',
      'dump_level_id',
      'enable_audio_recording',
      'capacity',
      'allow_receive_rate_limit',
      'send_billing_information',
      'diversion_policy_id',
      'diversion_rewrite_rule',
      'diversion_rewrite_result',
      'src_name_rewrite_rule',
      'src_name_rewrite_result',
      'src_rewrite_rule',
      'src_rewrite_result',
      'dst_rewrite_rule',
      'dst_rewrite_result',
      'radius_auth_profile_id',
      'src_number_radius_rewrite_rule',
      'src_number_radius_rewrite_result',
      'dst_number_radius_rewrite_rule',
      'dst_number_radius_rewrite_result',
      'radius_accounting_profile_id',
      'transport_protocol_id',
      'require_incoming_auth',
      'tag_action_id',
      'tag_action_value'
  ]


  self.import_class = ::CustomersAuth

  def self.after_import_hook(unique_columns = [])
    self.where(src_prefix: nil).update_all(src_prefix: '')
    self.where(dst_prefix: nil).update_all(dst_prefix: '')
    self.resolve_array_of_tags('tag_action_value', 'tag_action_value_names')
    super
  end

end
