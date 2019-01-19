# frozen_string_literal: true

FactoryGirl.define do
  factory :pop, class: Pop do
    sequence(:name) { |n| "Point of presence #{n}" }
  end
end
