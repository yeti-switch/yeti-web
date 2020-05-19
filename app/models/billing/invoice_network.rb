# frozen_string_literal: true

# == Schema Information
#
# Table name: invoice_networks
#
#  id                       :integer          not null, primary key
#  country_id               :integer
#  network_id               :integer
#  rate                     :decimal(, )
#  calls_count              :integer
#  calls_duration           :integer
#  amount                   :decimal(, )
#  invoice_id               :integer          not null
#  first_call_at            :datetime
#  last_call_at             :datetime
#  successful_calls_count   :integer
#  first_successful_call_at :datetime
#  last_successful_call_at  :datetime
#  billing_duration         :integer
#

class Billing::InvoiceNetwork < Cdr::Base
  belongs_to :invoice, class_name: 'Billing::Invoice', foreign_key: :invoice_id
  belongs_to :country, class_name: 'System::Country', foreign_key: :country_id
  belongs_to :network, class_name: 'System::Network', foreign_key: :network_id

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
