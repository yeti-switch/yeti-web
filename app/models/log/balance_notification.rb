# frozen_string_literal: true

# == Schema Information
#
# Table name: logs.balance_notifications
#
#  id                     :bigint(8)        not null, primary key
#  account_balance        :decimal(, )      not null
#  balance_high_threshold :decimal(, )
#  balance_low_threshold  :decimal(, )
#  created_at             :timestamptz      not null
#  account_id             :integer(4)       not null
#  event_id               :integer(2)       not null
#
# Indexes
#
#  balance_notifications_account_id_idx  (account_id)
#

class Log::BalanceNotification < ApplicationRecord
  self.table_name = 'logs.balance_notifications'

  module CONST
    EVENT_ID_LOW_THRESHOLD_CLEARED = 1
    EVENT_ID_HIGH_THRESHOLD_CLEARED = 2
    EVENT_ID_LOW_THRESHOLD_REACHED = 3
    EVENT_ID_HIGH_THRESHOLD_REACHED = 4
    EVENT_IDS = [
      EVENT_ID_LOW_THRESHOLD_CLEARED,
      EVENT_ID_HIGH_THRESHOLD_CLEARED,
      EVENT_ID_LOW_THRESHOLD_REACHED,
      EVENT_ID_HIGH_THRESHOLD_REACHED
    ].freeze
    EVENTS = {
      EVENT_ID_LOW_THRESHOLD_CLEARED => 'Low Threshold Cleared',
      EVENT_ID_HIGH_THRESHOLD_CLEARED => 'High Threshold Cleared',
      EVENT_ID_LOW_THRESHOLD_REACHED => 'Low Threshold Reached',
      EVENT_ID_HIGH_THRESHOLD_REACHED => 'High Threshold Reached'
    }.freeze

    freeze
  end

  belongs_to :account

  validates :event_id, inclusion: { in: CONST::EVENT_IDS }
  validates :account_balance, presence: true

  def display_name
    "#{id} | #{event} #{account_id}"
  end

  def event
    CONST::EVENTS.fetch(event_id)
  end
end
