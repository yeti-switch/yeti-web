# frozen_string_literal: true

FactoryBot.define do
  factory :active_call, class: RealtimeData::ActiveCall do
    trait :filled do
      duration { (rand(60) + rand).round(7) }
      start_time { rand(120..179).seconds.ago.to_f }
      connect_time { 2.minutes.ago.to_f }
      end_time { nil }
      local_tag { [1, 2, 16, 8].map { |n| SecureRandom.hex(n).upcase }.join('-') }
      local_time { Time.now.to_f }
      sequence(:node_id, 1)
      vendor_acc_id { Account.vendors_accounts.last&.id || 124 }
      vendor_id { Contractor.vendors.last&.id || 123 }

      active_resources { '[]' }
      active_resources_json { [] }
      attempt_num { 1 }
      audio_record_enabled { false }
      auth_orig_ip { '192.168.88.23' }
      auth_orig_port { 5060 }
      auth_orig_protocol_id { 1 }
      cdr_born_time { 1.minute.ago.to_f }
      customer_acc_check_balance { true }
      customer_acc_external_id { nil }
      customer_acc_id { 25 }
      customer_acc_vat { '0' }
      customer_auth_external_id { nil }
      customer_auth_id { 20_085 }
      customer_auth_name { 'test auth' }
      customer_external_id { nil }
      customer_id { 5 }
      destination_fee { '0.0' }
      destination_id { 4_201_541 }
      destination_initial_interval { 1 }
      destination_initial_rate { '0.11' }
      destination_next_interval { 1 }
      destination_next_rate { '0.11' }
      destination_prefix { '380' }
      destination_rate_policy_id { 1 }
      destination_reverse_billing { false }
      dialpeer_fee { '0.0' }
      dialpeer_id { 1_376_786 }
      dialpeer_initial_interval { 1 }
      dialpeer_initial_rate { '0.005' }
      dialpeer_next_interval { 1 }
      dialpeer_next_rate { '0.001' }
      dialpeer_prefix { '380' }
      dialpeer_reverse_billing { false }
      disconnect_code { 0 }
      disconnect_initiator { 4 }
      disconnect_internal_code { 0 }
      disconnect_internal_reason { 'Unhandled sequence' }
      disconnect_reason { '' }
      diversion_in { nil }
      diversion_out { nil }
      dst_area_id { nil }
      dst_country_id { 222 }
      dst_network_id { 1522 }
      dst_prefix_in { '9810441492550028' }
      dst_prefix_out { '3800000000000000000' }
      dst_prefix_routing { '3800000000000000000' }
      dump_level_id { 0 }
      from_domain { '192.168.88.23' }
      global_tag { '' }
      legA_local_ip { '192.168.88.23' }
      legA_local_port { 5061 }
      legA_remote_ip { '192.168.88.23' }
      legA_remote_port { 5060 }
      legB_local_ip { '' }
      legB_local_port { 0 }
      legB_remote_ip { '' }
      legB_remote_port { 0 }
      lnp_database_id { nil }
      lrn { nil }
      orig_call_id { '2141402782-1223087865-286388420' }
      orig_gw_external_id { nil }
      orig_gw_id { 19 }
      pai_in { nil }
      pai_out { nil }
      pop_id { 4 }
      ppi_in { nil }
      ppi_out { nil }
      privacy_in { nil }
      privacy_out { nil }
      rateplan_id { 18 }
      resources { '' }
      routing_group_id { 24 }
      routing_plan_id { 3 }
      routing_tag_ids { '{}' }
      rpid_in { nil }
      rpid_out { nil }
      rpid_privacy_in { nil }
      rpid_privacy_out { nil }
      ruri_domain { '192.168.88.23' }
      src_area_id { nil }
      src_name_in { '' }
      src_name_out { '' }
      src_prefix_in { '10317' }
      src_prefix_out { '10317' }
      src_prefix_routing { '10317' }
      term_call_id { '8-5D73A55A-5CFB77360000494D-19C01700' }
      term_gw_external_id { nil }
      term_gw_id { 20 }
      time_limit { 4909 }
      to_domain { '192.168.12.88' }
      vendor_acc_external_id { nil }
      vendor_external_id { nil }
    end
  end
end
