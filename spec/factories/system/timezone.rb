# frozen_string_literal: true

FactoryBot.define do
  factory :timezone, class: System::Timezone do
    sequence(:name) { |n| "TZ#{n}" }
    sequence(:abbrev) { |n| "TZ#{n}" }
    utc_offset { 0 }
    is_dst { false }

    trait :los_angeles do
      name { 'America/Los_Angeles' }
      abbrev { 'PDT' }
      utc_offset { -28_800 }
      is_dst { true }
    end

    trait :kiev do
      name { 'Europe/Kiev' }
      abbrev { 'PDT' }
      utc_offset { 7200 }
      is_dst { true }
    end
  end
end
