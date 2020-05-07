# frozen_string_literal: true

# == Schema Information
#
# Table name: notifications.alerts
#
#  id      :integer          not null, primary key
#  event   :string           not null
#  send_to :integer          is an Array
#

FactoryGirl.define do
  factory :notification_alert, class: Notification::Alert do
    sequence(:event) { |n| "DialpeerLocked #{n}" }
  end
end
