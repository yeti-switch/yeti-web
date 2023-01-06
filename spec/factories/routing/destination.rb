# frozen_string_literal: true

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
