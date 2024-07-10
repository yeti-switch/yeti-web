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
#  dst_number_field_name            :integer(2)
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
#  pop_name                         :string
#  radius_accounting_profile_name   :string
#  radius_auth_profile_name         :string
#  rateplan_name                    :string
#  reject_calls                     :boolean
#  require_incoming_auth            :boolean
#  routing_group_name               :string
#  routing_plan_name                :string
#  send_billing_information         :boolean          default(FALSE), not null
#  src_name_field_name              :integer(2)
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
#  diversion_policy_id              :integer(4)
#  dst_number_field_id              :integer(2)
#  dst_numberlist_id                :integer(4)
#  dump_level_id                    :integer(4)
#  gateway_id                       :integer(4)
#  lua_script_id                    :integer(2)
#  o_id                             :bigint(8)
#  pop_id                           :integer(4)
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
FactoryBot.define do
  factory :importing_customers_auth, class: Importing::CustomersAuth do
    transient do
      _tag_action { Routing::TagAction.last }
      _routing_tags { create_list(:routing_tag, 2) }
    end

    o_id { nil }
    error_string { nil }

    customer_name { nil }
    customer_id { nil }
    rateplan_name { nil }
    rateplan_id { nil }
    enabled { true }
    account_name { nil }
    account_id { nil }
    gateway_name { nil }
    gateway_id { nil }
    src_rewrite_rule { nil }
    src_rewrite_result { nil }
    dst_rewrite_rule { nil }
    dst_rewrite_result { nil }
    name { nil }
    dump_level_name { nil }
    dump_level_id { 1 }
    capacity { 1 }
    pop_name { nil }
    pop_id { nil }
    src_name_rewrite_rule { nil }
    src_name_rewrite_result { nil }
    diversion_policy_name { nil }
    diversion_policy_id { 1 }
    diversion_rewrite_rule { nil }
    diversion_rewrite_result { nil }
    dst_numberlist_id { nil }
    dst_numberlist_name { nil }
    src_numberlist_id { nil }
    src_numberlist_name { nil }
    routing_plan_name { nil }
    routing_plan_id { nil }
    allow_receive_rate_limit { false }
    send_billing_information { false }
    enable_audio_recording { false }
    check_account_balance { true }
    require_incoming_auth { false }

    ip { '196.168.0.1, 127.0.0.0/8' }
    src_prefix { 'src-1, src-2' }
    src_number_min_length { 5 }
    src_number_max_length { 10 }
    dst_prefix { 'dst-1, dst-2' }
    dst_number_min_length { 6 }
    dst_number_max_length { 10 }
    x_yeti_auth { 'x-1, x-2' }
    uri_domain { 'uri-1, uri-2' }
    from_domain { 'from-1, from-2' }
    to_domain { 'to-1, to-2' }

    tag_action_name { _tag_action.name }
    tag_action_id { _tag_action.id }

    tag_action_value_names { _routing_tags.map(&:name).join(', ') }
    tag_action_value { _routing_tags.map(&:id) }
  end
end
