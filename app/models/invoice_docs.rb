# frozen_string_literal: true

# god object to generate files for invoice
class InvoiceDocs
  # PLACEHOLDERS
  # ACC_NAME,
  # ACC_BALANCE,
  # ACC_MIN_BALANCE,
  # ACC_MAX_BALANCE,
  # ACC_INV_PERIOD
  # CONTRACTOR_NAME,
  # CONTRACTOR_ADDRESS,
  # CONTRACTOR_PHONES,
  # INV_CREATED_AT,
  # INV_START_DATE,
  # INV_END_DATE,
  # INV_AMOUNT,
  # INV_CALLS_COUNT,
  # INV_FIRST_CALL_DATE,
  # INV_LAST_CALL_DATE
  # INV_DST_TABLE,
  # INV_DST_COUNTRY,
  # INV_DST_NETWORK,
  # INV_DST_RATE,
  # INV_DST_CALLS_COUNT,
  # INV_DST_CALLS_DURATION,
  # INV_DST_AMOUNT,
  # INV_DST_FIRST_CALL_AT,
  # INV_DST_LAST_CALL_AT

  attr_reader :invoice

  class TemplateUndefined < RuntimeError
  end

  def initialize(invoice)
    @invoice = invoice
  end

  def save!
    raise TemplateUndefined, "Template blank for invoice: #{invoice.id}" if template.blank?

    # ?
    File.open(file_name, 'wb') do |file|
      file.write(template.data)
    end

    save_invoice!
  end

  def self.replaces_list
    %w[
      acc_name
      acc_balance
      acc_balance_decorated
      acc_min_balance
      acc_min_balance_decorated
      acc_max_balance
      acc_max_balance_decorated
      acc_inv_period
      contractor_name
      contractor_address
      contractor_phones
      inv_id
      inv_created_at
      inv_start_date
      inv_end_date
      inv_amount
      inv_amount_decorated
      inv_calls_count
      inv_successful_calls_count
      inv_calls_durationm
      inv_calls_duration_dec
      inv_calls_duration
      inv_first_call_at
      inv_first_successful_call_at
      inv_last_call_at
      inv_last_successful_call_at
    ]
  end

  private

  def replaces
    {
      acc_name: invoice.account.name,
      acc_balance: invoice.account.balance,
      acc_balance_decorated: AccountDecorator.new(invoice.account).decorated_balance,
      acc_min_balance: invoice.account.min_balance,
      acc_min_balance_decorated: AccountDecorator.new(invoice.account).decorated_min_balance,
      acc_max_balance: invoice.account.max_balance,
      acc_max_balance_decorated: AccountDecorator.new(invoice.account).decorated_max_balance,
      acc_inv_period: invoice.invoice_period.try(:name),
      contractor_name: invoice.contractor.name,
      contractor_address: invoice.contractor.address,
      contractor_phones: invoice.contractor.phones,
      inv_id: invoice.id,
      inv_created_at: invoice.created_at,
      inv_start_date: invoice.start_date,
      inv_end_date: invoice.end_date,
      inv_amount: invoice.amount,
      inv_amount_decorated: InvoiceDecorator.new(invoice).decorated_amount,
      inv_calls_count: invoice.calls_count,
      inv_successful_calls_count: invoice.successful_calls_count,
      inv_calls_durationm: InvoiceDecorator.new(invoice).decorated_calls_duration_kolon,
      inv_calls_duration_dec: InvoiceDecorator.new(invoice).decorated_calls_duration_dec,
      inv_calls_duration: invoice.calls_duration,
      inv_first_call_at: invoice.first_call_at,
      inv_first_successful_call_at: invoice.first_successful_call_at,
      inv_last_call_at: invoice.last_call_at,
      inv_last_successful_call_at: invoice.last_successful_call_at
    }
  end

  def save_invoice!
    odf_path = file_name
    odf_data = ODFReport::Report.new(file_name) do |r|
      replaces.each do |k, v|
        r.add_field k, v
      end
      r.add_table('INV_DST_TABLE', InvoiceDestinationDecorator.decorate_collection(invoice.destinations.for_invoice.order('dst_prefix').to_a), header: true, footer: true) do |t|
        t.add_column(:dst_prefix)
        t.add_column(:country) { |field| field.country.try(:name) }
        t.add_column(:network) { |field| field.network.try(:name) }
        t.add_column(:rate)
        t.add_column(:calls_count)
        t.add_column(:successful_calls_count)
        t.add_column(:calls_duration)
        t.add_column(:calls_durationm, &:decorated_calls_duration_kolon)
        t.add_column(:calls_duration_dec, &:decorated_calls_duration_dec)
        t.add_column(:amount)
        t.add_column(:amount_decorated, &:decorated_amount)
        t.add_column(:first_call_at)
        t.add_column(:last_call_at)
        t.add_column(:first_successful_call_at)
        t.add_column(:last_successful_call_at)
      end
      r.add_table('INV_NETWORKS_TABLE', InvoiceNetworkDecorator.decorate_collection(invoice.networks.for_invoice.order('country_id, network_id').to_a), header: true, footer: true) do |t|
        t.add_column(:country) { |field| field.country.try(:name) }
        t.add_column(:network) { |field| field.network.try(:name) }
        t.add_column(:rate)
        t.add_column(:calls_count)
        t.add_column(:successful_calls_count)
        t.add_column(:calls_duration)
        t.add_column(:calls_durationm, &:decorated_calls_duration_kolon)
        t.add_column(:calls_duration_dec, &:decorated_calls_duration_dec)
        t.add_column(:amount)
        t.add_column(:amount_decorated, &:decorated_amount)
        t.add_column(:first_call_at)
        t.add_column(:last_call_at)
        t.add_column(:first_successful_call_at)
        t.add_column(:last_successful_call_at)
      end
    end.generate(odf_path) # New ODFReport constructor return data, not a file name

    # generate pdf
    Open3.popen3("HOME=/opt/yeti-web /usr/bin/unoconv -f pdf #{Shellwords.escape(odf_path)}") do |_stdin, _stdout, _stderr, wait_thr|
      wait_thr.value # Process::Status object returned.
    end

    base_name = File.basename(odf_path, '.*')
    pdf_path = File.join(File.dirname(odf_path), "#{base_name}.pdf")

    odf_data = begin
      File.read(odf_path)
               rescue StandardError => e
                 logger.error { e.message }
                 logger.error { e.backtrace.join("\n") }
                 nil
    end

    pdf_data = begin
      File.read(pdf_path)
               rescue StandardError => e
                 logger.error { e.message }
                 logger.error { e.backtrace.join("\n") }
                 nil
    end

    csv_data = invoice.destinations.to_csv

    Billing::InvoiceDocument.create!(
      invoice_id: invoice.id,
      filename: invoice.file_name.to_s,
      data: odf_data,
      pdf_data: pdf_data,
      csv_data: csv_data,
      xls_data: Excelinator.csv_to_xls(csv_data)
    )
  end

  def template
    invoice.odt_template
  end

  def file_name
    @file_name ||= "tmp/invoice-template-#{template.filename}"
  end

  def logger
    Rails.logger
  end
end
