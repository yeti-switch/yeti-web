# frozen_string_literal: true

FactoryBot.define do
  factory :filter_types, class: FilterType do
    sequence(:name) { |n| "filter_type#{n}" }
  end
end
