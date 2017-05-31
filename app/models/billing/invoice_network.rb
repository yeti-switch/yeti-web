
class Billing::InvoiceNetwork < Cdr::Base

  belongs_to :invoice, class_name: 'Billing::Invoice', foreign_key: :invoice_id
  belongs_to :country, class_name: 'System::Country', foreign_key: :country_id
  belongs_to :network, class_name: 'System::Network', foreign_key: :network_id

  def self.for_invoice
    includes(:country, :network)
  end

  def self.to_csv
    csv_string = CSV.generate do |csv|
      csv << ["COUNTRY",	"NETWORK", "RATE",	"CALLS COUNT","SUCCESSFUL CALLS COUNT", "DURATION",	"AMOUNT"]

      self.for_invoice.each do |record|
        csv << [record.country.try!(:name), record.network.try!(:name), record.rate,
                record.calls_count, record.successful_calls_count, record.calls_duration, record.amount ]
      end
    end
    csv_string
  end

end
