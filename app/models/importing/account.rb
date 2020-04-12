# frozen_string_literal: true

# == Schema Information
#
# Table name: data_import.import_accounts
#
#  id                             :integer          not null, primary key
#  o_id                           :integer
#  contractor_name                :string
#  contractor_id                  :integer
#  balance                        :decimal(, )
#  min_balance                    :decimal(, )
#  max_balance                    :decimal(, )
#  name                           :string
#  origination_capacity           :integer
#  termination_capacity           :integer
#  error_string                   :string
#  invoice_period_id              :integer
#  invoice_period_name            :string
#  autogenerate_vendor_invoices   :boolean          default(FALSE), not null
#  autogenerate_customer_invoices :boolean          default(FALSE), not null
#  balance_high_threshold         :decimal(, )
#  balance_low_threshold          :decimal(, )
#  total_capacity                 :integer
#  destination_rate_limit         :decimal(, )
#  vat                            :decimal(, )
#  max_call_duration              :integer
#  is_changed                     :boolean
#

class Importing::Account < Importing::Base
  self.table_name = 'data_import.import_accounts'
  attr_accessor :file
  belongs_to :contractor, class_name: '::Contractor'

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
