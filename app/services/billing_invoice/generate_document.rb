# frozen_string_literal: true

# god object to generate files for invoice

module BillingInvoice
  class GenerateDocument < ApplicationService
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
    # INV_REF

    class TemplateUndefined < Error
      def initialize(invoice_id)
        super("Template blank for invoice: #{invoice_id}")
      end
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
        inv_ref
        inv_created_at
        inv_start_date
        inv_end_date
        inv_orig_amount
        inv_orig_amount_decorated
        inv_orig_calls_count
        inv_orig_successful_calls_count
        inv_orig_calls_durationm
        inv_orig_calls_duration_dec
        inv_orig_calls_duration
        inv_orig_first_call_at
        inv_orig_last_call_at
        inv_term_amount
        inv_term_amount_decorated
        inv_term_calls_count
        inv_term_successful_calls_count
        inv_term_calls_durationm
        inv_term_calls_duration_dec
        inv_term_calls_duration
        inv_term_first_call_at
        inv_term_last_call_at
      ]
    end

    parameter :invoice, required: true

    def call
      raise TemplateUndefined, invoice.id if template.blank?

      odf_path = "tmp/invoice-template-#{template.filename}"
      File.open(odf_path, 'wb') do |file|
        file.write(template.data)
      end

      generate_odf_document(odf_path)

      # generate pdf
      convert_to_pdf(odf_path)

      base_name = File.basename(odf_path, '.*')
      pdf_path = File.join(File.dirname(odf_path), "#{base_name}.pdf")
      odf_data = save_read_file(odf_path)
      pdf_data = save_read_file(pdf_path)

      Billing::InvoiceDocument.create!(
          invoice: invoice,
          filename: invoice.file_name.to_s,
          data: odf_data,
          pdf_data: pdf_data
        )
    end

    private

    # @!method template
    #   Odt template
    def template
      invoice.account.invoice_template
    end

    def replaces
      decorated_account = AccountDecorator.new(invoice.account)
      decorated_invoice = InvoiceDecorator.new(invoice)
      {
        acc_name: invoice.account.name,
        acc_balance: invoice.account.balance,
        acc_balance_decorated: decorated_account.decorated_balance,
        acc_min_balance: invoice.account.min_balance,
        acc_min_balance_decorated: decorated_account.decorated_min_balance,
        acc_max_balance: invoice.account.max_balance,
        acc_max_balance_decorated: decorated_account.decorated_max_balance,
        acc_inv_period: invoice.invoice_period.try(:name),
        contractor_name: invoice.contractor.name,
        contractor_address: invoice.contractor.address,
        contractor_phones: invoice.contractor.phones,
        inv_id: invoice.id,
        inv_ref: invoice.reference,
        inv_created_at: invoice.created_at,
        inv_start_date: invoice.start_date,
        inv_end_date: invoice.end_date,

        inv_orig_amount_spent: invoice.originated_amount_spent,
        inv_orig_amount_earned: invoice.originated_amount_earned,
        inv_orig_amount_spent_decorated: decorated_invoice.decorated_originated_amount_spent,
        inv_orig_amount_earned_decorated: decorated_invoice.decorated_originated_amount_earned,

        inv_orig_calls_count: invoice.originated_calls_count,
        inv_orig_successful_calls_count: invoice.originated_successful_calls_count,
        inv_orig_calls_durationm: decorated_invoice.decorated_originated_calls_duration_kolon,
        inv_orig_calls_duration_dec: decorated_invoice.decorated_originated_calls_duration_dec,
        inv_orig_calls_duration: invoice.originated_calls_duration,
        inv_orig_first_call_at: invoice.first_originated_call_at,
        inv_orig_last_call_at: invoice.last_originated_call_at,

        inv_term_amount_spent: invoice.terminated_amount_spent,
        inv_term_amount_searned: invoice.terminated_amount_earned,
        inv_term_amount_decorated_spent: decorated_invoice.decorated_terminated_amount_spent,
        inv_term_amount_decorated_earned: decorated_invoice.decorated_terminated_amount_earned,

        inv_term_calls_count: invoice.terminated_calls_count,
        inv_term_first_call_at: invoice.first_terminated_call_at,
        inv_term_last_call_at: invoice.last_terminated_call_at,
        inv_term_calls_durationm: decorated_invoice.decorated_terminated_calls_duration_kolon,
        inv_term_calls_duration_dec: decorated_invoice.decorated_terminated_calls_duration_dec,
        inv_term_calls_duration: invoice.terminated_calls_duration,
        inv_term_successful_calls_count: invoice.terminated_successful_calls_count
      }
    end

    def generate_odf_document(odf_path)
      originated_destinations = InvoiceOriginatedDestinationDecorator.decorate_collection(
        invoice.originated_destinations.for_invoice.order('dst_prefix').to_a
      )
      terminated_destinations = InvoiceTerminatedDestinationDecorator.decorate_collection(
        invoice.originated_destinations.for_invoice.order('dst_prefix').to_a
      )

      originated_networks = InvoiceOriginatedNetworkDecorator.decorate_collection(
        invoice.originated_networks.for_invoice.order('country_id, network_id').to_a
      )
      terminated_networks = InvoiceTerminatedNetworkDecorator.decorate_collection(
        invoice.terminated_networks.for_invoice.order('country_id, network_id').to_a
      )

      ODFReport::Report.new(odf_path) do |r|
        replaces.each do |k, v|
          r.add_field k, v
        end
        r.add_table('INV_ORIG_DST_TABLE', originated_destinations, header: true, footer: true) do |t|
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
        end
        r.add_table('INV_TERM_DST_TABLE', terminated_destinations, header: true, footer: true) do |t|
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
        end
        r.add_table('INV_ORIG_NETWORKS_TABLE', originated_networks, header: true, footer: true) do |t|
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
        end
        r.add_table('INV_TERM_NETWORKS_TABLE', terminated_networks, header: true, footer: true) do |t|
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
        end
      end.generate(odf_path) # New ODFReport constructor return data, not a file name
    end

    def convert_to_pdf(odf_path)
      pdf_command = "HOME=/opt/yeti-web /usr/bin/unoconv -f pdf #{Shellwords.escape(odf_path)}"
      Open3.popen3(pdf_command) do |_stdin, _stdout, _stderr, wait_thr|
        wait_thr.value # Process::Status object returned.
      end
    end

    def save_read_file(file_path)
      File.read(file_path)
    rescue StandardError => e
      logger.error { e.message }
      logger.error { e.backtrace.join("\n") }
      capture_error(e, extra: { service_class: self.class.name, file_path: file_path })
      nil
    end
  end
end
