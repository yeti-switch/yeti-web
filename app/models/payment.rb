# frozen_string_literal: true

# == Schema Information
#
# Table name: payments
#
#  id                     :bigint(8)        not null, primary key
#  amount                 :decimal(, )      not null
#  balance_before_payment :decimal(, )
#  notes                  :string
#  private_notes          :string
#  uuid                   :uuid             not null
#  created_at             :timestamptz      not null
#  account_id             :integer(4)       not null
#  status_id              :integer(2)       default(20), not null
#  type_id                :integer(2)       default(20), not null
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

    TYPE_ID_CRYPTOMUS = 10
    TYPE_ID_MANUAL = 20
    TYPE_IDS = {
      TYPE_ID_CRYPTOMUS => 'cryptomus',
      TYPE_ID_MANUAL => 'manual'
    }.freeze

    freeze
  end

  include WithPaperTrail

  belongs_to :account, class_name: 'Account'

  validates :amount, presence: true
  validates :amount, numericality: { other_than: 0 }, allow_nil: true

  validate :validate_status_id

  validates :type_id, presence: true, on: :create
  validates :type_id, inclusion: { in: CONST::TYPE_IDS.keys }, allow_nil: true, on: :create
  validates :type_id, readonly: true, on: :update

  before_save :top_up_balance

  # creates scopes status_eq status_not_eq status_in status_not_in
  define_enum_scopes(name: :status, allowed_values: CONST::STATUS_IDS)

  # creates scopes type_name_eq type_name_not_eq type_name_in type_name_not_in
  define_enum_scopes(name: :type_name, id_column: :type_id, allowed_values: CONST::TYPE_IDS)

  scope :today, lambda {
    where('created_at >= ? ', Time.now.at_beginning_of_day)
  }

  scope :yesterday, lambda {
    where('created_at >= ? and created_at < ?', 1.day.ago.at_beginning_of_day, Time.now.at_beginning_of_day)
  }

  scope :type_cryptomus, -> { where(type_id: CONST::TYPE_ID_CRYPTOMUS) }

  def status
    CONST::STATUS_IDS[status_id]
  end

  def type_name
    CONST::TYPE_IDS[type_id]
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

  def type_manual?
    type_id == CONST::TYPE_ID_MANUAL
  end

  def type_cryptomus?
    type_id == CONST::TYPE_ID_CRYPTOMUS
  end

  def display_name
    "Payment ##{id}"
  end

  def self.ransackable_scopes(_auth_object = nil)
    enum_scope_names(:status) + enum_scope_names(:type_name)
  end

  private

  def top_up_balance
    if (new_record? || status_id_changed?) && completed?
      account.lock! # will generate SELECT FOR UPDATE SQL statement
      self.balance_before_payment = account.balance
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

    if persisted? && status_id_changed? && status_id_was == Payment::CONST::STATUS_ID_COMPLETED
      errors.add(:status_id, 'is readonly')
    end

    if new_record? && type_manual? && !completed?
      errors.add(:status_id, 'must be completed for manual payments')
    end
  end
end
