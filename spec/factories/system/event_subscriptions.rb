# frozen_string_literal: true

# == Schema Information
#
# Table name: notifications.event_subscriptions
#
#  id      :integer(4)       not null, primary key
#  event   :string           not null
#  send_to :integer(4)       is an Array
#
# Indexes
#
#  alerts_event_key  (event) UNIQUE
#

FactoryBot.define do
  factory :event_subscription, class: System::EventSubscription do
    sequence(:event) { |n| "DialpeerLocked #{n}" }
  end
end
