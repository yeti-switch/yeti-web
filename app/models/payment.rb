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
  belongs_to :account

  include WithPaperTrail

  validates :amount, numericality: true
  validates :account, presence: true

  before_create do
    account.lock! # will generate SELECT FOR UPDATE SQL statement
    account.balance += amount
    throw(:abort) unless account.save
  end

  scope :today, -> { where('created_at >= ? ', Time.now.at_beginning_of_day) }
  scope :yesterday, -> { where('created_at >= ? and created_at < ?', 1.day.ago.at_beginning_of_day, Time.now.at_beginning_of_day) }
end
