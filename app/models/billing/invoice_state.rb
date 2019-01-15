# frozen_string_literal: true

# == Schema Information
#
# Table name: billing.invoice_states
#
#  id   :integer          not null, primary key
#  name :string           not null
#

class Billing::InvoiceState < Cdr::Base
  self.table_name = 'billing.invoice_states'

  PENDING = 1
  APPROVED = 2
end
