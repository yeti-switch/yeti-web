# frozen_string_literal: true

# == Schema Information
#
# Table name: billing.transactions
#
#  id          :bigint(8)        not null, primary key
#  amount      :decimal(, )      not null
#  description :string
#  uuid        :uuid             not null
#  created_at  :timestamptz      not null
#  account_id  :integer(4)       not null
#  service_id  :bigint(8)
#
# Indexes
#
#  transactions_account_id_idx  (account_id)
#  transactions_service_id_idx  (service_id)
#  transactions_uuid_idx        (uuid)
#
# Foreign Keys
#
#  transactions_account_id_fkey  (account_id => accounts.id)
#
class Billing::Transaction < ApplicationRecord
  self.table_name = 'billing.transactions'

  belongs_to :account, class_name: 'Account'
  belongs_to :service, class_name: 'Billing::Service', optional: true

  validates :amount, presence: true
  validates :amount, numericality: { other_than: 0 }, allow_nil: true
  validate :validate_account_service, on: :create

  attr_readonly :amount, :account_id, :service_id

  before_create :charge_account

  scope :today, lambda {
    where('created_at >= ? ', Time.now.at_beginning_of_day)
  }

  scope :yesterday, lambda {
    where('created_at >= ? and created_at < ?', 1.day.ago.at_beginning_of_day, Time.now.at_beginning_of_day)
  }

  def display_name
    "Transaction ##{id}"
  end

  private

  def validate_account_service
    return if account.nil? || service.nil?

    errors.add(:service, 'belongs to different account') if service.account_id != account_id
  end

  def charge_account
    account.lock! # will generate SELECT FOR UPDATE SQL statement
    account.balance -= amount
    unless account.save
      errors.add(:base, "Unable to charge account: #{account.errors.full_messages.to_sentence}")
      throw(:abort)
    end
  end
end
