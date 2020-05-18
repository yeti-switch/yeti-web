# frozen_string_literal: true

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
