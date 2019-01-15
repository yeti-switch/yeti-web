# frozen_string_literal: true

FactoryGirl.define do
  factory :disconnect_policy, class: DisconnectPolicy do
    sequence(:name) { |n| "disconnect_policy#{n}" }
  end
end
