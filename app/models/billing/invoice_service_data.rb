# frozen_string_literal: true

# == Schema Information
#
# Table name: billing.invoice_service_data
#
#  id                 :bigint(8)        not null, primary key
#  amount             :decimal(, )      not null
#  spent              :boolean          default(TRUE), not null
#  transactions_count :integer(4)       not null
#  invoice_id         :integer(4)       not null
#  service_id         :bigint(8)
#
# Indexes
#
#  invoice_service_data_invoice_id_idx  (invoice_id)
#
# Foreign Keys
#
#  invoice_service_data_invoice_id_fkey  (invoice_id => invoices.id)
#
class Billing::InvoiceServiceData < Cdr::Base
  self.table_name = 'billing.invoice_service_data'

  belongs_to :invoice, class_name: 'Billing::Invoice', foreign_key: :invoice_id
  belongs_to :service, class_name: 'Billing::Service', optional: true

  scope :for_invoice, -> { preload(:service).order(:spent, :service_id) }

  def self.summary
    select("
      COALESCE(SUM(transactions_count), 0) as transactions_count,
      COALESCE(sum(amount) FILTER (WHERE spent), 0) as amount_spent,
      COALESCE(sum(amount) FILTER (WHERE NOT spent),0) as amount_earned
    ").to_a[0]
  end
end
