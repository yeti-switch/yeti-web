# == Schema Information
#
# Table name: invoice_destinations
#
#  id                       :integer          not null, primary key
#  dst_prefix               :string
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
      csv << ["DST PREFIX",	"COUNTRY",	"NETWORK", "RATE",	"CALLS COUNT","SUCCESSFUL CALLS COUNT", "DURATION",	"AMOUNT"]

      self.for_invoice.each do |record|
        csv << [record.dst_prefix, record.country.try!(:name), record.network.try!(:name), record.rate,
                record.calls_count, record.successful_calls_count, record.calls_duration, record.amount ]
      end
    end
    csv_string
  end

  def self.summary
    self.select("
      coalesce(sum(calls_count),0) as calls_count,
      coalesce(sum(successful_calls_count),0) as successful_calls_count,
      coalesce(sum(calls_duration),0) as calls_duration,
      COALESCE(sum(amount),0) as amount,
      min(first_call_at) as first_call_at,
      min(first_successful_call_at) as first_successful_call_at,
      max(last_call_at) as last_call_at,
      max(last_successful_call_at) as last_successful_call_at
    ").to_a[0]
  end

end
