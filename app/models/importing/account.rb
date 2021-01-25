# frozen_string_literal: true

# == Schema Information
#
# Table name: data_import.import_accounts
#
#  id                             :bigint(8)        not null, primary key
#  autogenerate_customer_invoices :boolean          default(FALSE), not null
#  autogenerate_vendor_invoices   :boolean          default(FALSE), not null
#  balance                        :decimal(, )
#  balance_high_threshold         :decimal(, )
#  balance_low_threshold          :decimal(, )
#  contractor_name                :string
#  destination_rate_limit         :decimal(, )
#  error_string                   :string
#  invoice_period_name            :string
#  is_changed                     :boolean
#  max_balance                    :decimal(, )
#  max_call_duration              :integer(4)
#  min_balance                    :decimal(, )
#  name                           :string
#  origination_capacity           :integer(4)
#  termination_capacity           :integer(4)
#  total_capacity                 :integer(2)
#  vat                            :decimal(, )
#  contractor_id                  :integer(4)
#  invoice_period_id              :integer(2)
#  o_id                           :integer(4)
#

class Importing::Account < Importing::Base
  self.table_name = 'data_import.import_accounts'
  attr_accessor :file
  belongs_to :contractor, class_name: '::Contractor', optional: true

  self.import_attributes = %w[
    contractor_id
    name
    balance
    vat
    min_balance
    max_balance
    origination_capacity
    termination_capacity
    total_capacity
    balance_high_threshold
    balance_low_threshold
    destination_rate_limit
    max_call_duration
  ]

  import_for ::Account
end
