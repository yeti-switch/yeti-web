# frozen_string_literal: true

# == Schema Information
#
# Table name: billing.invoice_types
#
#  id   :integer          not null, primary key
#  name :string           not null
#

class Billing::InvoiceType < Cdr::Base
  self.table_name = 'billing.invoice_types'

  MANUAL = 1
  AUTO_FULL = 2
  AUTO_PARTIAL = 3
end
