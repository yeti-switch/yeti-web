# frozen_string_literal: true

# == Schema Information
#
# Table name: invoice_networks
#
#  id                       :bigint(8)        not null, primary key
#  amount                   :decimal(, )
#  billing_duration         :bigint(8)
#  calls_count              :bigint(8)
#  calls_duration           :bigint(8)
#  first_call_at            :timestamptz
#  first_successful_call_at :timestamptz
#  last_call_at             :timestamptz
#  last_successful_call_at  :timestamptz
#  rate                     :decimal(, )
#  successful_calls_count   :bigint(8)
#  country_id               :integer(4)
#  invoice_id               :integer(4)       not null
#  network_id               :integer(4)
#
# Indexes
#
#  invoice_networks_invoice_id_idx  (invoice_id)
#
# Foreign Keys
#
#  invoice_networks_invoice_id_fkey  (invoice_id => invoices.id)
#

class Billing::InvoiceNetwork < Cdr::Base
  belongs_to :invoice, class_name: 'Billing::Invoice', foreign_key: :invoice_id
  belongs_to :country, class_name: 'System::Country', foreign_key: :country_id, optional: true
  belongs_to :network, class_name: 'System::Network', foreign_key: :network_id, optional: true

  def self.for_invoice
    includes(:country, :network)
  end

  def self.to_csv
    csv_string = CSV.generate do |csv|
      csv << ['COUNTRY',	'NETWORK', 'RATE',	'CALLS COUNT', 'SUCCESSFUL CALLS COUNT', 'DURATION', 'BILLING DURATION', 'AMOUNT']

      for_invoice.each do |record|
        csv << [record.country&.name, record.network&.name, record.rate,
                record.calls_count, record.successful_calls_count, record.calls_duration, record.billing_duration, record.amount]
      end
    end
    csv_string
  end
end
