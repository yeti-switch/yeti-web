# frozen_string_literal: true

FactoryGirl.define do
  factory :sorting, class: Sorting do
    sequence(:name) { |n| "Sorting_#{n}" }
  end
end
