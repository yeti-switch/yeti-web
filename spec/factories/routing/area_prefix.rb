# frozen_string_literal: true

FactoryGirl.define do
  factory :area_prefix, class: Routing::AreaPrefix do
    sequence(:prefix) { |n| "#{n}#{n + 1}#{n + 2}" } # example: '123', '234'...

    association :area
  end
end
