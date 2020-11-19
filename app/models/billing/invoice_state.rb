# frozen_string_literal: true

# == Schema Information
#
# Table name: billing.invoice_states
#
#  id   :integer(2)       not null, primary key
#  name :string           not null
#
# Indexes
#
#  invoice_states_name_key  (name) UNIQUE
#

class Billing::InvoiceState < Cdr::Base
  self.table_name = 'billing.invoice_states'

  PENDING = 1
  APPROVED = 2
  NEW = 3
end
