# frozen_string_literal: true

# == Schema Information
#
# Table name: invoice_destinations
#
#  id                       :bigint(8)        not null, primary key
#  amount                   :decimal(, )
#  billing_duration         :bigint(8)
#  calls_count              :bigint(8)
#  calls_duration           :bigint(8)
#  dst_prefix               :string
#  first_call_at            :datetime
#  first_successful_call_at :datetime
#  last_call_at             :datetime
#  last_successful_call_at  :datetime
#  rate                     :decimal(, )
#  successful_calls_count   :bigint(8)
#  country_id               :integer(4)
#  invoice_id               :integer(4)       not null
#  network_id               :integer(4)
#
# Indexes
#
#  invoice_destinations_invoice_id_idx  (invoice_id)
#
# Foreign Keys
#
#  invoice_destinations_invoice_id_fkey  (invoice_id => invoices.id)
#

class Billing::InvoiceDestination < Cdr::Base
  belongs_to :invoice, class_name: 'Billing::Invoice', foreign_key: :invoice_id
  belongs_to :country, class_name: 'System::Country', foreign_key: :country_id
  belongs_to :network, class_name: 'System::Network', foreign_key: :network_id

  def self.for_invoice
    includes(:country, :network)
  end

  def self.to_csv
    csv_string = CSV.generate do |csv|
      csv << ['DST PREFIX',	'COUNTRY',	'NETWORK', 'RATE',	'CALLS COUNT', 'SUCCESSFUL CALLS COUNT', 'DURATION', 'BILLING DURATION', 'AMOUNT']

      for_invoice.each do |record|
        csv << [record.dst_prefix, record.country&.name, record.network&.name, record.rate,
                record.calls_count, record.successful_calls_count, record.calls_duration, record.billing_duration, record.amount]
      end
    end
    csv_string
  end

  def self.summary
    select("
      coalesce(sum(calls_count),0) as calls_count,
      coalesce(sum(successful_calls_count),0) as successful_calls_count,
      coalesce(sum(calls_duration),0) as calls_duration,
      coalesce(sum(billing_duration),0) as billing_duration,
      COALESCE(sum(amount),0) as amount,
      min(first_call_at) as first_call_at,
      min(first_successful_call_at) as first_successful_call_at,
      max(last_call_at) as last_call_at,
      max(last_successful_call_at) as last_successful_call_at
    ").to_a[0]
  end
end
