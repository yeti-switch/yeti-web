# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.destinations
#
#  id                     :bigint(8)        not null, primary key
#  acd_limit              :float            default(0.0), not null
#  allow_package_billing  :boolean          default(FALSE), not null
#  asr_limit              :float            default(0.0), not null
#  connect_fee            :decimal(, )      default(0.0)
#  dp_margin_fixed        :decimal(, )      default(0.0), not null
#  dp_margin_percent      :decimal(, )      default(0.0), not null
#  dst_number_max_length  :integer(2)       default(100), not null
#  dst_number_min_length  :integer(2)       default(0), not null
#  enabled                :boolean          not null
#  initial_interval       :integer(4)       default(1), not null
#  initial_rate           :decimal(, )      not null
#  next_interval          :integer(4)       default(1), not null
#  next_rate              :decimal(, )      not null
#  prefix                 :string           not null
#  quality_alarm          :boolean          default(FALSE), not null
#  reject_calls           :boolean          default(FALSE), not null
#  reverse_billing        :boolean          default(FALSE), not null
#  routing_tag_ids        :integer(2)       default([]), not null, is an Array
#  short_calls_limit      :float            default(0.0), not null
#  use_dp_intervals       :boolean          default(FALSE), not null
#  uuid                   :uuid             not null
#  valid_from             :timestamptz      not null
#  valid_till             :timestamptz      not null
#  external_id            :bigint(8)
#  network_prefix_id      :integer(4)
#  profit_control_mode_id :integer(2)
#  rate_group_id          :integer(4)       not null
#  rate_policy_id         :integer(4)       default(1), not null
#  routing_tag_mode_id    :integer(2)       default(0), not null
#
# Indexes
#
#  destinations_prefix_range_idx  (((prefix)::prefix_range)) USING gist
#  destinations_uuid_key          (uuid) UNIQUE
#
# Foreign Keys
#
#  destinations_rate_group_id_fkey        (rate_group_id => rate_groups.id)
#  destinations_routing_tag_mode_id_fkey  (routing_tag_mode_id => routing_tag_modes.id)
#
FactoryBot.define do
  factory :destination, aliases: [:rate], class: Routing::Destination do
    sequence(:external_id)
    prefix { nil }
    connect_fee { 0 }
    enabled { true }
    reverse_billing { false }
    reject_calls { false }
    initial_interval { 60 }
    next_interval { 60 }
    initial_rate { 0 }
    next_rate { 0 }
    rate_policy_id { 1 }
    dp_margin_fixed { 0 }
    dp_margin_percent { 0 }
    use_dp_intervals { false }
    valid_from { 1.day.ago.utc }
    valid_till { 1.day.from_now.utc }
    profit_control_mode_id { Routing::RateProfitControlMode::MODE_PER_CALL }

    association :rate_group

    trait :with_uuid do
      uuid { SecureRandom.uuid }
    end

    trait :filled do
      with_uuid
    end
  end
end
