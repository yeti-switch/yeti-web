# frozen_string_literal: true

# == Schema Information
#
# Table name: invoice_periods
#
#  id   :integer(2)       not null, primary key
#  name :string           not null
#
# Indexes
#
#  invoice_periods_name_key  (name) UNIQUE
#

class Billing::InvoicePeriod < ApplicationRecord
  DAILY_ID = 1
  WEEKLY_ID = 2
  BIWEEKLY_ID = 3
  MONTHLY_ID = 4
  BIWEEKLY_SPLIT_ID = 5
  WEEKLY_SPLIT_ID = 6

  validates :name, uniqueness: true, presence: true
end
