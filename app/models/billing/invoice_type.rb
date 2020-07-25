# frozen_string_literal: true

# == Schema Information
#
# Table name: billing.invoice_types
#
#  id   :integer(2)       not null, primary key
#  name :string           not null
#
# Indexes
#
#  invoice_types_name_key  (name) UNIQUE
#

class Billing::InvoiceType < Cdr::Base
  self.table_name = 'billing.invoice_types'

  MANUAL = 1
  AUTO_FULL = 2
  AUTO_PARTIAL = 3

  NAMES = {
    MANUAL => 'Manual',
    AUTO_FULL => 'Auto Full',
    AUTO_PARTIAL => 'Auto Partial'
  }.freeze
end
