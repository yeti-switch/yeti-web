# frozen_string_literal: true

# == Schema Information
#
# Table name: billing.account_balance_notification_settings
#
#  id             :bigint(8)        not null, primary key
#  high_threshold :decimal(, )
#  low_threshold  :decimal(, )
#  send_to        :integer(4)       is an Array
#  account_id     :bigint(8)        not null
#  state_id       :integer(2)       default(0), not null
#
# Indexes
#
#  account_balance_notification_settings_account_id_uniq_idx  (account_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_f185d22f87  (account_id => accounts.id)
#
class AccountBalanceNotificationSetting < ApplicationRecord
  self.table_name = 'billing.account_balance_notification_settings'

  module CONST
    STATE_ID_NONE = 0
    STATE_ID_LOW_THRESHOLD = 1
    STATE_ID_HIGH_THRESHOLD = 2
    STATE_IDS = [STATE_ID_NONE, STATE_ID_LOW_THRESHOLD, STATE_ID_HIGH_THRESHOLD].freeze
    STATES = {
      STATE_ID_NONE => 'None',
      STATE_ID_LOW_THRESHOLD => 'Low Threshold',
      STATE_ID_HIGH_THRESHOLD => 'High Threshold'
    }.freeze

    freeze
  end

  belongs_to :account, class_name: 'Account', inverse_of: :balance_notification_setting

  validates :account_id, readonly: true
  validates :state_id, inclusion: { in: CONST::STATE_IDS }

  def contacts
    @contacts ||= Billing::Contact.where(id: send_to)
  end

  def send_to=(send_to_ids)
    @contacts = nil # clear cached #contacts
    self[:send_to] = send_to_ids&.reject(&:blank?)
  end

  def send_to_emails
    contacts.map(&:email).join(',')
  end

  def state
    CONST::STATES.fetch(state_id)
  end

  def state_low_threshold?
    state_id == CONST::STATE_ID_LOW_THRESHOLD
  end

  def state_high_threshold?
    state_id == CONST::STATE_ID_HIGH_THRESHOLD
  end

  def state_none?
    state_id == CONST::STATE_ID_NONE
  end

  def low_threshold_reached?
    return false if low_threshold.nil?

    account.balance < low_threshold
  end

  def high_threshold_reached?
    return false if high_threshold.nil?

    account.balance > high_threshold
  end
end
