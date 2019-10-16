# frozen_string_literal: true

# == Schema Information
#
# Table name: disconnect_policy
#
#  id   :integer          not null, primary key
#  name :string
#

FactoryGirl.define do
  factory :disconnect_policy, class: DisconnectPolicy do
    sequence(:name) { |n| "disconnect_policy#{n}" }
  end
end
