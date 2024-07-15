# frozen_string_literal: true

# == Schema Information
#
# Table name: disconnect_policy
#
#  id   :integer(4)       not null, primary key
#  name :string
#
# Indexes
#
#  disconnect_code_policy_name_key  (name) UNIQUE
#

FactoryBot.define do
  factory :disconnect_policy, class: 'DisconnectPolicy' do
    sequence(:name) { |n| "disconnect_policy#{n}" }

    trait :filled do
      gateways { build_list :gateway, 2 }
    end
  end
end
