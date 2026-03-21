# frozen_string_literal: true

# == Schema Information
#
# Table name: data_import.import_accounts
#
#  id                             :bigint(8)        not null, primary key
#  autogenerate_customer_invoices :boolean          default(FALSE), not null
#  autogenerate_vendor_invoices   :boolean          default(FALSE), not null
#  balance                        :decimal(, )
#  contractor_name                :string
#  currency_name                  :string
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
#  currency_id                    :integer(2)
#  invoice_period_id              :integer(2)
#  o_id                           :integer(4)
#

class Importing::Account < Importing::Base
  self.table_name = 'data_import.import_accounts'
  attr_accessor :file
  belongs_to :contractor, class_name: '::Contractor', optional: true
  belongs_to :currency, class_name: '::Billing::Currency', optional: true

  self.import_attributes = %w[
    contractor_id
    currency_id
    name
    balance
    vat
    min_balance
    max_balance
    origination_capacity
    termination_capacity
    total_capacity
    destination_rate_limit
    max_call_duration
  ]

  self.strict_unique_attributes = %w[name]

  import_for ::Account
end
