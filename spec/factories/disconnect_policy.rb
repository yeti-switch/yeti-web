# frozen_string_literal: true

# == Schema Information
#
# Table name: disconnect_policy
#
#  id   :integer          not null, primary key
#  name :string
#

FactoryBot.define do
  factory :disconnect_policy, class: DisconnectPolicy do
    sequence(:name) { |n| "disconnect_policy#{n}" }

    trait :filled do
      gateways { build_list :gateway, 2 }
    end
  end
end
