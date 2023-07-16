# frozen_string_literal: true

# == Schema Information
#
# Table name: payments
#
#  id            :bigint(8)        not null, primary key
#  amount        :decimal(, )      not null
#  notes         :string
#  private_notes :string
#  uuid          :uuid             not null
#  created_at    :timestamptz      not null
#  account_id    :integer(4)       not null
#  status_id     :integer(2)       not null
#
# Indexes
#
#  payments_account_id_idx  (account_id)
#  payments_uuid_key        (uuid) UNIQUE
#
# Foreign Keys
#
#  payments_account_id_fkey  (account_id => accounts.id)
#

class Payment < ApplicationRecord
  module CONST
    STATUS_ID_CANCELED = 10
    STATUS_ID_COMPLETED = 20
    STATUS_ID_PENDING = 30
    STATUS_IDS = {
      STATUS_ID_CANCELED => 'canceled',
      STATUS_ID_COMPLETED => 'completed',
      STATUS_ID_PENDING => 'pending'
    }.freeze

    freeze
  end

  include WithPaperTrail

  attribute :status_id, :integer, default: CONST::STATUS_ID_COMPLETED

  belongs_to :account, class_name: 'Account'

  validates :amount, presence: true
  validates :amount, numericality: { other_than: 0 }, allow_nil: true

  validate :validate_status_id

  before_save :top_up_balance

  # eq not_eq in not_in
  scope :status_eq, lambda { |value|
    status_id = CONST::STATUS_IDS.key(value)
    status_id ? where(status_id:) : none
  }

  scope :status_not_eq, lambda { |value|
    status_id = CONST::STATUS_IDS.key(value)
    status_id ? where.not(status_id:) : all
  }

  scope :status_in, lambda { |*values|
    status_ids = values.map { |value| CONST::STATUS_IDS.key(value) }.compact
    status_ids.present? ? where(status_id: status_ids) : none
  }

  scope :status_not_in, lambda { |*values|
    status_ids = values.map { |value| CONST::STATUS_IDS.key(value) }.compact
    status_ids.present? ? where.not(status_id: status_ids) : all
  }

  scope :today, lambda {
    where('created_at >= ? ', Time.now.at_beginning_of_day)
  }

  scope :yesterday, lambda {
    where('created_at >= ? and created_at < ?', 1.day.ago.at_beginning_of_day, Time.now.at_beginning_of_day)
  }

  def status
    CONST::STATUS_IDS[status_id]
  end

  def completed?
    status_id == CONST::STATUS_ID_COMPLETED
  end

  def canceled?
    status_id == CONST::STATUS_ID_CANCELED
  end

  def pending?
    status_id == CONST::STATUS_ID_PENDING
  end

  def self.ransackable_scopes(_auth_object = nil)
    %i[status_eq status_not_eq status_in status_not_in]
  end

  private

  def top_up_balance
    if status_id_changed? && completed?
      account.lock! # will generate SELECT FOR UPDATE SQL statement
      account.balance += amount
      throw(:abort) unless account.save
    end
  end

  def validate_status_id
    if status_id.nil?
      errors.add(:status_id, :blank)
      return
    end

    if CONST::STATUS_IDS.keys.exclude?(status_id)
      errors.add(:status_id, :inclusion, value: status_id)
      return
    end

    if status_id_changed? && status_id_was == Payment::CONST::STATUS_ID_COMPLETED
      errors.add(:status_id, :readonly)
    end
  end
end
