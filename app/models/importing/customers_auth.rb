# frozen_string_literal: true

# == Schema Information
#
# Table name: data_import.import_customers_auth
#
#  id                               :bigint(8)        not null, primary key
#  account_name                     :string
#  allow_receive_rate_limit         :boolean          default(FALSE), not null
#  capacity                         :integer(4)
#  check_account_balance            :boolean
#  cps_limit                        :float
#  customer_name                    :string
#  diversion_policy_name            :string
#  diversion_rewrite_result         :string
#  diversion_rewrite_rule           :string
#  dst_number_field_name            :string
#  dst_number_max_length            :integer(4)
#  dst_number_min_length            :integer(4)
#  dst_number_radius_rewrite_result :string
#  dst_number_radius_rewrite_rule   :string
#  dst_numberlist_name              :string
#  dst_prefix                       :string
#  dst_rewrite_result               :string
#  dst_rewrite_rule                 :string
#  dump_level_name                  :string
#  enable_audio_recording           :boolean
#  enabled                          :boolean
#  error_string                     :string
#  from_domain                      :string
#  gateway_name                     :string
#  ip                               :string
#  is_changed                       :boolean
#  lua_script_name                  :string
#  max_dst_number_length            :integer(2)
#  min_dst_number_length            :integer(2)
#  name                             :string
#  pai_policy_name                  :string
#  pai_rewrite_result               :string
#  pai_rewrite_rule                 :string
#  pop_name                         :string
#  privacy_mode_name                :string
#  radius_accounting_profile_name   :string
#  radius_auth_profile_name         :string
#  rateplan_name                    :string
#  reject_calls                     :boolean
#  require_incoming_auth            :boolean
#  routing_group_name               :string
#  routing_plan_name                :string
#  send_billing_information         :boolean          default(FALSE), not null
#  src_name_field_name              :string
#  src_name_rewrite_result          :string
#  src_name_rewrite_rule            :string
#  src_number_field_name            :string
#  src_number_max_length            :integer(2)
#  src_number_min_length            :integer(2)
#  src_number_radius_rewrite_result :string
#  src_number_radius_rewrite_rule   :string
#  src_numberlist_name              :string
#  src_prefix                       :string
#  src_rewrite_result               :string
#  src_rewrite_rule                 :string
#  tag_action_name                  :string
#  tag_action_value                 :integer(2)       default([]), not null, is an Array
#  tag_action_value_names           :string
#  to_domain                        :string
#  transport_protocol_name          :string
#  uri_domain                       :string
#  x_yeti_auth                      :string
#  account_id                       :integer(4)
#  customer_id                      :integer(4)
#  diversion_policy_id              :integer(2)
#  dst_number_field_id              :integer(2)
#  dst_numberlist_id                :integer(4)
#  dump_level_id                    :integer(4)
#  gateway_id                       :integer(4)
#  lua_script_id                    :integer(2)
#  o_id                             :bigint(8)
#  pai_policy_id                    :integer(2)
#  pop_id                           :integer(4)
#  privacy_mode_id                  :integer(2)
#  radius_accounting_profile_id     :integer(2)
#  radius_auth_profile_id           :integer(2)
#  rateplan_id                      :integer(4)
#  routing_group_id                 :integer(4)
#  routing_plan_id                  :integer(4)
#  src_name_field_id                :integer(2)
#  src_number_field_id              :integer(2)
#  src_numberlist_id                :integer(4)
#  tag_action_id                    :integer(2)
#  transport_protocol_id            :integer(2)
#

class Importing::CustomersAuth < Importing::Base
  self.table_name = 'data_import.import_customers_auth'
  attr_accessor :file

  belongs_to :gateway, class_name: '::Gateway', optional: true
  belongs_to :account, class_name: '::Account', optional: true
  belongs_to :routing_plan, class_name: '::Routing::RoutingPlan', foreign_key: :routing_plan_id, optional: true
  belongs_to :rateplan, class_name: 'Routing::Rateplan', optional: true
  belongs_to :pop, class_name: '::Pop', optional: true
  belongs_to :customer, -> { where customer: true }, class_name: '::Contractor', foreign_key: :customer_id, optional: true

  belongs_to :dst_numberlist, class_name: '::Routing::Numberlist', foreign_key: :dst_numberlist_id, optional: true
  belongs_to :src_numberlist, class_name: '::Routing::Numberlist', foreign_key: :src_numberlist_id, optional: true
  belongs_to :radius_auth_profile, class_name: '::Equipment::Radius::AuthProfile', foreign_key: :radius_auth_profile_id, optional: true
  belongs_to :radius_accounting_profile, class_name: '::Equipment::Radius::AccountingProfile', foreign_key: :radius_accounting_profile_id, optional: true
  belongs_to :tag_action, class_name: 'Routing::TagAction', optional: true
  belongs_to :lua_script, class_name: 'System::LuaScript', foreign_key: :lua_script_id, optional: true

  self.import_attributes = %w[
    enabled
    reject_calls
    name
    ip
    pop_id
    src_prefix src_number_min_length src_number_max_length
    dst_prefix dst_number_min_length dst_number_max_length
    uri_domain
    from_domain
    to_domain
    x_yeti_auth
    customer_id
    account_id
    check_account_balance
    gateway_id
    rateplan_id
    routing_plan_id
    dst_numberlist_id
    src_numberlist_id
    dump_level_id
    privacy_mode_id
    enable_audio_recording
    capacity
    allow_receive_rate_limit
    send_billing_information
    diversion_policy_id
    diversion_rewrite_rule
    diversion_rewrite_result
    pai_policy_id
    pai_rewrite_rule
    pai_rewrite_result
    src_name_rewrite_rule
    src_name_rewrite_result
    src_rewrite_rule
    src_rewrite_result
    dst_rewrite_rule
    dst_rewrite_result
    radius_auth_profile_id
    src_number_radius_rewrite_rule
    src_number_radius_rewrite_result
    dst_number_radius_rewrite_rule
    dst_number_radius_rewrite_result
    radius_accounting_profile_id
    transport_protocol_id
    require_incoming_auth
    tag_action_id
    tag_action_value
    lua_script_id
  ]

  import_for ::CustomersAuth

  def transport_protocol_display_name
    transport_protocol_id.nil? ? 'Any' : CustomersAuth::TRANSPORT_PROTOCOLS[transport_protocol_id]
  end

  def dump_level_display_name
    dump_level_id.nil? ? 'unknown' : CustomersAuth::DUMP_LEVELS[dump_level_id]
  end

  def diversion_policy_display_name
    diversion_policy_id.nil? ? 'unknown' : CustomersAuth::DIVERSION_POLICIES[diversion_policy_id]
  end

  def pai_policy_display_name
    pai_policy_id.nil? ? 'unknown' : CustomersAuth::PAI_POLICIES[pai_policy_id]
  end

  def self.after_import_hook
    where(src_prefix: nil).update_all(src_prefix: '')
    where(dst_prefix: nil).update_all(dst_prefix: '')
    resolve_array_of_tags('tag_action_value', 'tag_action_value_names')
    resolve_integer_constant('transport_protocol_id', 'transport_protocol_name', CustomersAuth::TRANSPORT_PROTOCOLS)
    resolve_integer_constant('dump_level_id', 'dump_level_name', CustomersAuth::DUMP_LEVELS)
    resolve_integer_constant('privacy_mode_id', 'privacy_mode_name', CustomersAuth::PRIVACY_MODES)
    resolve_integer_constant('diversion_policy_id', 'diversion_policy_name', CustomersAuth::DIVERSION_POLICIES)
    resolve_integer_constant('pai_policy_id', 'pai_policy_name', CustomersAuth::PAI_POLICIES)
    resolve_integer_constant('src_name_field_id', 'src_name_field_name', CustomersAuth::SRC_NAME_FIELDS)
    resolve_integer_constant('src_number_field_id', 'src_number_field_name', CustomersAuth::SRC_NUMBER_FIELDS)
    resolve_integer_constant('dst_number_field_id', 'dst_number_field_name', CustomersAuth::DST_NUMBER_FIELDS)
    super
    CustomersAuth.increment_state_value
  end

  def self.calc_changed_conditions(orig_table, import_table)
    conditions = import_attributes.map do |col|
      if col == 'ip'
        "#{orig_table}.#{col}::varchar[] <> string_to_array(#{import_table}.#{col}, ',')::varchar[]"
      elsif col.in? %w[src_prefix dst_prefix uri_domain from_domain to_domain x_yeti_auth]
        "#{orig_table}.#{col} <> string_to_array(#{import_table}.#{col}, ',')::varchar[]"
      else
        "#{orig_table}.#{col} <> #{import_table}.#{col}"
      end
    end
    conditions.join(' OR ')
  end
end
