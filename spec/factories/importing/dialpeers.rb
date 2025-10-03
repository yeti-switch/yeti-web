# frozen_string_literal: true

# == Schema Information
#
# Table name: import_dialpeers
#
#  id                          :bigint(8)        not null, primary key
#  account_name                :string
#  acd_limit                   :float(24)
#  asr_limit                   :float(24)
#  capacity                    :integer(4)
#  connect_fee                 :decimal(, )
#  dst_number_max_length       :integer(4)
#  dst_number_min_length       :integer(4)
#  dst_rewrite_result          :string
#  dst_rewrite_rule            :string
#  enabled                     :boolean
#  error_string                :string
#  exclusive_route             :boolean
#  force_hit_rate              :float
#  gateway_group_name          :string
#  gateway_name                :string
#  initial_interval            :integer(4)
#  initial_rate                :decimal(, )
#  is_changed                  :boolean
#  lcr_rate_multiplier         :decimal(, )
#  locked                      :boolean
#  next_interval               :integer(4)
#  next_rate                   :decimal(, )
#  prefix                      :string
#  priority                    :integer(4)
#  reverse_billing             :boolean
#  routeset_discriminator_name :string
#  routing_group_name          :string
#  routing_tag_ids             :integer(2)       default([]), not null, is an Array
#  routing_tag_mode_name       :string
#  routing_tag_names           :string
#  scheduler_name              :string
#  short_calls_limit           :float(24)        default(1.0), not null
#  src_name_rewrite_result     :string
#  src_name_rewrite_rule       :string
#  src_rewrite_result          :string
#  src_rewrite_rule            :string
#  valid_from                  :datetime
#  valid_till                  :datetime
#  vendor_name                 :string
#  account_id                  :integer(4)
#  gateway_group_id            :integer(4)
#  gateway_id                  :integer(4)
#  o_id                        :bigint(8)
#  routeset_discriminator_id   :integer(2)
#  routing_group_id            :integer(4)
#  routing_tag_mode_id         :integer(2)
#  scheduler_id                :integer(2)
#  vendor_id                   :integer(4)
#
FactoryBot.define do
  factory :importing_dialpeer, class: 'Importing::Dialpeer' do
    transient do
      _tags { create_list(:routing_tag, 2) }
    end

    o_id { nil }
    error_string { nil }

    enabled { true }
    prefix { nil }
    src_rewrite_rule { nil }
    dst_rewrite_rule { nil }
    acd_limit { 0 }
    asr_limit { 0 }
    gateway_name { nil }
    gateway_id { nil }
    next_rate { nil }
    connect_fee { nil }
    vendor_name { nil }
    vendor_id { nil }
    account_name { nil }
    account_id { nil }
    src_rewrite_result { nil }
    dst_rewrite_result { nil }
    locked { false }
    priority { 100 }
    capacity { 0 }
    lcr_rate_multiplier { 1 }
    initial_rate { 0.0 }
    initial_interval { 60 }
    next_interval { 60 }
    valid_from { '1970-01-01 00:00:00' }
    valid_till { '2020-01-01 00:00:00' }
    gateway_group_id { nil }
    reverse_billing { false }

    dst_number_min_length { 1 }
    dst_number_max_length { 7 }

    routing_tag_ids { _tags.map(&:id) }
    routing_tag_names { _tags.map(&:name).join(', ') }

    trait :with_names do
      after(:build) do |record, _ev|
        record.vendor_name = record.vendor.name if record.vendor.present?
        record.account_name = record.account.name if record.account.present?
        record.gateway_name = record.gateway.name if record.gateway.present?
        record.gateway_group_name = record.gateway_group.name if record.gateway_group.present?
        record.routing_group_name = record.routing_group.name if record.routing_group.present?
        record.routing_tag_mode_name = record.routing_tag_mode.name if record.routing_tag_mode.present?
        record.routeset_discriminator_name = record.routeset_discriminator.name if record.routeset_discriminator.present?
      end
    end
  end
end
