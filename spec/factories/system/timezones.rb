# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.timezones
#
#  id         :integer(4)       not null, primary key
#  abbrev     :string
#  is_dst     :boolean
#  name       :string           not null
#  utc_offset :interval
#
# Indexes
#
#  timezones_name_key  (name) UNIQUE
#
FactoryBot.define do
  factory :timezone, class: 'System::Timezone' do
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

    trait :kyiv do
      name { 'Europe/Kyiv' }
      abbrev { 'EET' }
      utc_offset { 7200 }
      is_dst { true }
    end
  end
end
