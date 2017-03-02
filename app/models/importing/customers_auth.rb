# == Schema Information
#
# Table name: data_import.import_customers_auth
#
#  id                       :integer          not null, primary key
#  o_id                     :integer
#  customer_name            :string
#  customer_id              :integer
#  routing_group_name       :string
#  routing_group_id         :integer
#  rateplan_name            :string
#  rateplan_id              :integer
#  enabled                  :boolean
#  account_name             :string
#  account_id               :integer
#  gateway_name             :string
#  gateway_id               :integer
#  src_rewrite_rule         :string
#  src_rewrite_result       :string
#  dst_rewrite_rule         :string
#  dst_rewrite_result       :string
#  src_prefix               :string
#  dst_prefix               :string
#  x_yeti_auth              :string
#  name                     :string
#  dump_level_id            :integer
#  dump_level_name          :string
#  capacity                 :integer
#  ip                       :inet
#  uri_domain               :string
#  pop_name                 :string
#  pop_id                   :integer
#  diversion_policy_id      :integer
#  diversion_policy_name    :string
#  diversion_rewrite_result :string
#  diversion_rewrite_rule   :string
#  src_name_rewrite_result  :string
#  src_name_rewrite_rule    :string
#  error_string             :string
#  dst_blacklist_id         :integer
#  dst_blacklist_name       :string
#  src_blacklist_id         :integer
#  src_blacklist_name       :string
#  allow_receive_rate_limit :boolean          default(FALSE), not null
#  send_billing_information :boolean          default(FALSE), not null
#  routing_plan_id          :integer
#  routing_plan_name        :string
#

class Importing::CustomersAuth  < Importing::Base
    self.table_name = 'data_import.import_customers_auth'
    attr_accessor :file

    belongs_to :gateway, class_name: '::Gateway'
    belongs_to :account, class_name: '::Account'
    belongs_to :routing_group, class_name: '::RoutingGroup'
    belongs_to :routing_plan, class_name: '::Routing::RoutingPlan', foreign_key: :routing_plan_id
    belongs_to :rateplan, class_name: '::Rateplan'
    belongs_to :pop, class_name: '::Pop'
    belongs_to :customer, -> { where customer: true }, class_name: '::Contractor', foreign_key: :customer_id
    belongs_to :diversion_policy, class_name: '::DiversionPolicy'
    belongs_to :dump_level, class_name: '::DumpLevel'

    belongs_to :dst_blacklist, class_name: '::Routing::Blacklist', foreign_key: :dst_blacklist_id
    belongs_to :src_blacklist, class_name: '::Routing::Blacklist', foreign_key: :src_blacklist_id
    belongs_to :radius_auth_profile, class_name: '::Equipment::Radius::AuthProfile', foreign_key: :radius_auth_profile_id
    belongs_to :radius_accounting_profile, class_name: '::Equipment::Radius::AccountingProfile', foreign_key: :radius_accounting_profile_id

    self.import_attributes = [
        'enabled',
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
        'gateway_id',
        'rateplan_id',
        'routing_plan_id',
        'dst_blacklist_id',
        'src_blacklist_id',
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
        'radius_accounting_profile_id'
    ]


    self.import_class = ::CustomersAuth


    def self.after_import_hook(unique_columns = [])
      self.where(src_prefix: nil).update_all(src_prefix: '')
      self.where(dst_prefix: nil).update_all(dst_prefix: '')
      super
    end

end
