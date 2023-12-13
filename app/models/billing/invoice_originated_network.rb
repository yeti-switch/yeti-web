# frozen_string_literal: true

# == Schema Information
#
# Table name: billing.invoice_originated_networks
#
#  id                     :bigint(8)        not null, primary key
#  amount                 :decimal(, )
#  billing_duration       :bigint(8)
#  calls_count            :bigint(8)
#  calls_duration         :bigint(8)
#  first_call_at          :timestamptz
#  last_call_at           :timestamptz
#  rate                   :decimal(, )
#  spent                  :boolean          default(TRUE), not null
#  successful_calls_count :bigint(8)
#  country_id             :integer(4)
#  invoice_id             :integer(4)       not null
#  network_id             :integer(4)
#
# Indexes
#
#  invoice_originated_networks_invoice_id_idx  (invoice_id)
#
# Foreign Keys
#
#  invoice_originated_networks_invoice_id_fkey  (invoice_id => invoices.id)
#

class Billing::InvoiceOriginatedNetwork < Cdr::Base
  self.table_name = 'billing.invoice_originated_networks'

  belongs_to :invoice, class_name: 'Billing::Invoice', foreign_key: :invoice_id
  belongs_to :country, class_name: 'System::Country', foreign_key: :country_id, optional: true
  belongs_to :network, class_name: 'System::Network', foreign_key: :network_id, optional: true

  scope :for_invoice, -> { preload(:country, :network).order(:spent, :country_id) }

  def self.to_csv
    csv_string = CSV.generate do |csv|
      csv << ['COUNTRY', 'NETWORK', 'RATE', 'CALLS COUNT', 'SUCCESSFUL CALLS COUNT', 'DURATION', 'BILLING DURATION', 'AMOUNT']

      for_invoice.each do |record|
        csv << [
          record.country&.name,
          record.network&.name,
          record.rate,
          record.calls_count,
          record.successful_calls_count,
          record.calls_duration,
          record.billing_duration,
          record.amount
        ]
      end
    end
    csv_string
  end
end
