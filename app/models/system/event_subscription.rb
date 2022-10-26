# frozen_string_literal: true

# == Schema Information
#
# Table name: notifications.event_subscriptions
#
#  id      :integer(4)       not null, primary key
#  event   :string           not null
#  send_to :integer(4)       is an Array
#  url     :string
#
# Indexes
#
#  alerts_event_key  (event) UNIQUE
#

class System::EventSubscription < ApplicationRecord
  self.table_name = 'notifications.event_subscriptions'

  module CONST
    EVENT_ACCOUNT_LOW_THRESHOLD_REACHED = 'AccountLowThesholdReached'
    EVENT_ACCOUNT_HIGH_THRESHOLD_REACHED = 'AccountHighThesholdReached'
    EVENT_ACCOUNT_LOW_THRESHOLD_CLEARED = 'AccountLowThesholdCleared'
    EVENT_ACCOUNT_HIGH_THRESHOLD_CLEARED = 'AccountHighThesholdCleared'
    EVENT_DESTINATION_QUALITY_ALARM_FIRED = 'DestinationQualityAlarmFired'
    EVENT_DESTINATION_QUALITY_ALARM_CLEARED = 'DestinationQualityAlarmCleared'
    EVENT_DIALPEER_LOCKED = 'DialpeerLocked'
    EVENT_DIALPEER_UNLOCKED = 'DialpeerUnlocked'
    EVENT_GATEWAY_LOCKED = 'GatewayLocked'
    EVENT_GATEWAY_UNLOCKED = 'GatewayUnlocked'

    EVENTS = [
      EVENT_ACCOUNT_LOW_THRESHOLD_REACHED,
      EVENT_ACCOUNT_HIGH_THRESHOLD_REACHED,
      EVENT_ACCOUNT_LOW_THRESHOLD_CLEARED,
      EVENT_ACCOUNT_HIGH_THRESHOLD_CLEARED,
      EVENT_DESTINATION_QUALITY_ALARM_FIRED,
      EVENT_DESTINATION_QUALITY_ALARM_CLEARED,
      EVENT_DIALPEER_LOCKED,
      EVENT_DIALPEER_UNLOCKED,
      EVENT_GATEWAY_LOCKED,
      EVENT_GATEWAY_UNLOCKED
    ].freeze
  end

  include WithPaperTrail
  include Hints

  validate do
    if send_to.present? && send_to.any?
      errors.add(:send_to, :invalid) if contacts.count != send_to.count
    end
  end

  def contacts
    @contacts ||= Billing::Contact.where(id: send_to)
  end

  def send_to=(send_to_ids)
    @contacts = nil # clear cached #contacts
    self[:send_to] = send_to_ids&.reject(&:blank?)
  end

  def display_name
    "#{event} | #{id}"
  end
end
