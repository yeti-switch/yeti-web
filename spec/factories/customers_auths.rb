# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.customers_auth
#
#  id                               :integer(4)       not null, primary key
#  allow_receive_rate_limit         :boolean          default(FALSE), not null
#  capacity                         :integer(2)
#  check_account_balance            :boolean          default(TRUE), not null
#  cps_limit                        :float
#  diversion_rewrite_result         :string
#  diversion_rewrite_rule           :string
#  dst_number_max_length            :integer(2)       default(100), not null
#  dst_number_min_length            :integer(2)       default(0), not null
#  dst_number_radius_rewrite_result :string
#  dst_number_radius_rewrite_rule   :string
#  dst_prefix                       :string           default(["\"\""]), is an Array
#  dst_rewrite_result               :string
#  dst_rewrite_rule                 :string
#  enable_audio_recording           :boolean          default(FALSE), not null
#  enabled                          :boolean          default(TRUE), not null
#  external_type                    :string
#  from_domain                      :string           default([]), is an Array
#  interface                        :string           default([]), not null, is an Array
#  ip                               :inet             default(["\"127.0.0.0/8\""]), is an Array
#  name                             :string           not null
#  pai_rewrite_result               :string
#  pai_rewrite_rule                 :string
#  reject_calls                     :boolean          default(FALSE), not null
#  require_incoming_auth            :boolean          default(FALSE), not null
#  send_billing_information         :boolean          default(FALSE), not null
#  src_name_rewrite_result          :string
#  src_name_rewrite_rule            :string
#  src_number_max_length            :integer(2)       default(100), not null
#  src_number_min_length            :integer(2)       default(0), not null
#  src_number_radius_rewrite_result :string
#  src_number_radius_rewrite_rule   :string
#  src_numberlist_use_diversion     :boolean          default(FALSE), not null
#  src_prefix                       :string           default(["\"\""]), is an Array
#  src_rewrite_result               :string
#  src_rewrite_rule                 :string
#  ss_dst_rewrite_result            :string
#  ss_dst_rewrite_rule              :string
#  ss_src_rewrite_result            :string
#  ss_src_rewrite_rule              :string
#  tag_action_value                 :integer(2)       default([]), not null, is an Array
#  to_domain                        :string           default([]), is an Array
#  uri_domain                       :string           default([]), is an Array
#  x_yeti_auth                      :string           default([]), is an Array
#  account_id                       :integer(4)
#  cnam_database_id                 :integer(2)
#  customer_id                      :integer(4)       not null
#  diversion_policy_id              :integer(2)       default(1), not null
#  dst_number_field_id              :integer(2)       default(1), not null
#  dst_numberlist_id                :integer(2)
#  dump_level_id                    :integer(2)       default(0), not null
#  external_id                      :bigint(8)
#  gateway_id                       :integer(4)       not null
#  lua_script_id                    :integer(2)
#  pai_policy_id                    :integer(2)       default(1), not null
#  pop_id                           :integer(4)
#  privacy_mode_id                  :integer(2)       default(1), not null
#  radius_accounting_profile_id     :integer(2)
#  radius_auth_profile_id           :integer(2)
#  rateplan_id                      :integer(4)       not null
#  rewrite_ss_status_id             :integer(2)
#  routing_plan_id                  :integer(4)       not null
#  src_name_field_id                :integer(2)       default(1), not null
#  src_number_field_id              :integer(2)       default(1), not null
#  src_numberlist_id                :integer(2)
#  ss_invalid_identity_action_id    :integer(2)       default(0), not null
#  ss_mode_id                       :integer(2)       default(0), not null
#  ss_no_identity_action_id         :integer(2)       default(0), not null
#  stir_shaken_crt_id               :integer(2)
#  tag_action_id                    :integer(2)
#  transport_protocol_id            :integer(2)
#
# Indexes
#
#  customers_auth_account_id_idx                      (account_id)
#  customers_auth_customer_id_idx                     (customer_id)
#  customers_auth_dst_numberlist_id_idx               (dst_numberlist_id)
#  customers_auth_external_id_external_type_key_uniq  (external_id,external_type) UNIQUE
#  customers_auth_external_id_key_uniq                (external_id) UNIQUE WHERE (external_type IS NULL)
#  customers_auth_name_key                            (name) UNIQUE
#  customers_auth_src_numberlist_id_idx               (src_numberlist_id)
#
# Foreign Keys
#
#  customers_auth_account_id_fkey                    (account_id => accounts.id)
#  customers_auth_cnam_database_id_fkey              (cnam_database_id => cnam_databases.id)
#  customers_auth_customer_id_fkey                   (customer_id => contractors.id)
#  customers_auth_dst_blacklist_id_fkey              (dst_numberlist_id => numberlists.id)
#  customers_auth_gateway_id_fkey                    (gateway_id => gateways.id)
#  customers_auth_lua_script_id_fkey                 (lua_script_id => lua_scripts.id)
#  customers_auth_pop_id_fkey                        (pop_id => pops.id)
#  customers_auth_radius_accounting_profile_id_fkey  (radius_accounting_profile_id => radius_accounting_profiles.id)
#  customers_auth_radius_auth_profile_id_fkey        (radius_auth_profile_id => radius_auth_profiles.id)
#  customers_auth_rateplan_id_fkey                   (rateplan_id => rateplans.id)
#  customers_auth_routing_plan_id_fkey               (routing_plan_id => routing_plans.id)
#  customers_auth_src_blacklist_id_fkey              (src_numberlist_id => numberlists.id)
#  customers_auth_tag_action_id_fkey                 (tag_action_id => tag_actions.id)
#
FactoryBot.define do
  factory :customers_auth, class: 'CustomersAuth' do
    sequence(:name) { |n| "customers_auth_#{n}" }
    diversion_policy_id { CustomersAuth::DIVERSION_POLICY_NOT_ACCEPT }
    dump_level_id { 1 }

    # ip { ['127.0.0.0/8'] } # default
    src_number_field_id { 1 }
    src_rewrite_rule { nil }
    src_rewrite_result { nil }

    dst_number_field_id { 1 }
    dst_rewrite_rule { nil }
    dst_rewrite_result { nil }

    pop_id { nil }

    src_name_field_id { 1 }
    src_name_rewrite_rule { nil }
    src_name_rewrite_result { nil }

    diversion_rewrite_rule { nil }
    diversion_rewrite_result { nil }
    dst_numberlist_id { nil }
    src_numberlist_id { nil }
    allow_receive_rate_limit { false }
    send_billing_information { false }

    association :rateplan
    association :routing_plan
    association :lua_script

    transient do
      gateway_traits { [] }
    end

    trait :with_incoming_auth do
      gateway_traits { %i[with_incoming_auth] }
      require_incoming_auth { true }
    end

    trait :with_reject do
      reject_calls { true }
    end

    trait :filled do
      with_incoming_auth
      with_reject
      tag_action { Routing::TagAction.take || FactoryBot.create(:tag_action) }
    end

    trait :with_external_id do
      sequence(:external_id)
    end

    after(:build) do |record, ev|
      record.customer ||= record.account.contractor if record.account
      record.customer ||= record.gateway.contractor if record.gateway
      record.customer ||= FactoryBot.create(:contractor, customer: true)

      record.account ||= FactoryBot.create(:account, contractor: record.customer)
      record.gateway ||= FactoryBot.create(:gateway, *ev.gateway_traits, contractor: record.customer)
    end
  end
end
