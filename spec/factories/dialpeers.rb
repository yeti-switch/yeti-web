# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.dialpeers
#
#  id                        :bigint(8)        not null, primary key
#  acd_limit                 :float            default(0.0), not null
#  asr_limit                 :float            default(0.0), not null
#  capacity                  :integer(2)
#  connect_fee               :decimal(, )      default(0.0), not null
#  dst_number_max_length     :integer(2)       default(100), not null
#  dst_number_min_length     :integer(2)       default(0), not null
#  dst_rewrite_result        :string
#  dst_rewrite_rule          :string
#  enabled                   :boolean          not null
#  exclusive_route           :boolean          default(FALSE), not null
#  force_hit_rate            :float
#  initial_interval          :integer(4)       default(1), not null
#  initial_rate              :decimal(, )      not null
#  lcr_rate_multiplier       :decimal(, )      default(1.0), not null
#  locked                    :boolean          default(FALSE), not null
#  next_interval             :integer(4)       default(1), not null
#  next_rate                 :decimal(, )      not null
#  prefix                    :string           not null
#  priority                  :integer(4)       default(100), not null
#  reverse_billing           :boolean          default(FALSE), not null
#  routing_tag_ids           :integer(2)       default([]), not null, is an Array
#  short_calls_limit         :float            default(1.0), not null
#  src_name_rewrite_result   :string
#  src_name_rewrite_rule     :string
#  src_rewrite_result        :string
#  src_rewrite_rule          :string
#  valid_from                :timestamptz      not null
#  valid_till                :timestamptz      not null
#  created_at                :timestamptz      not null
#  account_id                :integer(4)       not null
#  current_rate_id           :bigint(8)
#  external_id               :bigint(8)
#  gateway_group_id          :integer(4)
#  gateway_id                :integer(4)
#  network_prefix_id         :integer(4)
#  routeset_discriminator_id :integer(2)       default(1), not null
#  routing_group_id          :integer(4)       not null
#  routing_tag_mode_id       :integer(2)       default(0), not null
#  vendor_id                 :integer(4)       not null
#
# Indexes
#
#  dialpeers_account_id_idx                           (account_id)
#  dialpeers_external_id_idx                          (external_id)
#  dialpeers_prefix_range_idx                         (((prefix)::prefix_range)) USING gist
#  dialpeers_prefix_range_valid_from_valid_till_idx   (((prefix)::prefix_range), valid_from, valid_till) WHERE enabled USING gist
#  dialpeers_prefix_range_valid_from_valid_till_idx1  (((prefix)::prefix_range), valid_from, valid_till) WHERE (enabled AND (NOT locked)) USING gist
#  dialpeers_vendor_id_idx                            (vendor_id)
#
# Foreign Keys
#
#  dialpeers_account_id_fkey                 (account_id => accounts.id)
#  dialpeers_gateway_group_id_fkey           (gateway_group_id => gateway_groups.id)
#  dialpeers_gateway_id_fkey                 (gateway_id => gateways.id)
#  dialpeers_routeset_discriminator_id_fkey  (routeset_discriminator_id => routeset_discriminators.id)
#  dialpeers_routing_group_id_fkey           (routing_group_id => routing_groups.id)
#  dialpeers_routing_tag_mode_id_fkey        (routing_tag_mode_id => routing_tag_modes.id)
#  dialpeers_vendor_id_fkey                  (vendor_id => contractors.id)
#
FactoryBot.define do
  factory :dialpeer, class: Dialpeer do
    sequence(:external_id)
    enabled { true }
    reverse_billing { false }
    prefix { nil }
    src_rewrite_rule { nil }
    dst_rewrite_rule { nil }
    acd_limit { 0 }
    asr_limit { 0 }
    gateway_id { nil }
    routing_group_id { nil }
    connect_fee { 0 }
    src_rewrite_result { nil }
    dst_rewrite_result { nil }
    locked { false }
    priority { 100 }
    capacity { 1 }
    lcr_rate_multiplier { 1 }
    next_rate { 0.0 }
    initial_rate { 0.0 }
    next_interval { 60 }
    initial_interval { 60 }

    valid_from { 10.days.ago.utc }
    valid_till { 10.days.from_now.utc }

    association :routing_group
    association :routeset_discriminator

    after :build do |dialpeer|
      dialpeer.vendor ||= create(:contractor, vendor: true)
      dialpeer.account ||= create(:account, contractor: dialpeer.vendor)
      dialpeer.gateway_group ||= create(:gateway_group, vendor: dialpeer.vendor) if dialpeer.gateway.blank?
    end
  end
end
