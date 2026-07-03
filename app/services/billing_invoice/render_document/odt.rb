# frozen_string_literal: true

module BillingInvoice
  module RenderDocument
    # Legacy ODT renderer: fills the account's ODT template with odf-report and
    # converts it to PDF via the configured YetiConfig.invoice.pdf_converter,
    # storing both the ODT and PDF bytes on the InvoiceDocument.
    #
    # This is the code that previously lived in BillingInvoice::GenerateDocument,
    # moved verbatim so the dispatcher can pick between it and the yeti-pdf
    # (HTML) path.
    class Odt < ApplicationService
      parameter :invoice, required: true

      def call
        with_tempfiles do |odf_file, pdf_file|
          odf_file.write(template.data)

          generate_odf_document(odf_file.path)

          # generate pdf
          convert_to_pdf(odf_file.path, pdf_file.path)

          odf_data = save_read_file(odf_file.path)
          pdf_data = save_read_file(pdf_file.path)

          Billing::InvoiceDocument.create!(
            invoice: invoice,
            filename: invoice.file_name.to_s,
            data: odf_data,
            pdf_data: pdf_data
          )
        end
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
          a_name: invoice.account.name,
          a_balance: invoice.account.balance,
          a_balance_d: decorated_account.decorated_balance,
          a_min_balance: invoice.account.min_balance,
          a_min_balance_d: decorated_account.decorated_min_balance,
          a_max_balance: invoice.account.max_balance,
          a_max_balance_d: decorated_account.decorated_max_balance,
          a_inv_period: invoice.invoice_period.try(:name),

          c_name: invoice.contractor.name,
          c_address: invoice.contractor.address,
          c_phones: invoice.contractor.phones,

          i_id: invoice.id,
          i_ref: invoice.reference,
          i_created_at: invoice.created_at,
          i_start_date: invoice.start_date,
          i_end_date: invoice.end_date,

          i_total: invoice.amount_total,
          i_total_d: decorated_invoice.decorated_amount_total,

          i_spent: invoice.amount_spent,
          i_spent_d: decorated_invoice.decorated_amount_spent,

          i_earned: invoice.amount_earned,
          i_earned_d: decorated_invoice.decorated_amount_earned,

          i_orig_spent: invoice.originated_amount_spent,
          i_orig_earned: invoice.originated_amount_earned,
          i_orig_spent_d: decorated_invoice.decorated_originated_amount_spent,
          i_orig_earned_d: decorated_invoice.decorated_originated_amount_earned,

          i_orig_calls_count: invoice.originated_calls_count,
          i_orig_successful_calls_count: invoice.originated_successful_calls_count,
          i_orig_calls_durationm: decorated_invoice.decorated_originated_calls_duration_kolon,
          i_orig_calls_duration_d: decorated_invoice.decorated_originated_calls_duration_dec,
          i_orig_calls_duration: invoice.originated_calls_duration,
          i_orig_first_call_at: invoice.first_originated_call_at,
          i_orig_last_call_at: invoice.last_originated_call_at,

          i_term_spent: invoice.terminated_amount_spent,
          i_term_earned: invoice.terminated_amount_earned,
          i_term_spent_d: decorated_invoice.decorated_terminated_amount_spent,
          i_term_earned_d: decorated_invoice.decorated_terminated_amount_earned,

          i_term_calls_count: invoice.terminated_calls_count,
          i_term_first_call_at: invoice.first_terminated_call_at,
          i_term_last_call_at: invoice.last_terminated_call_at,
          i_term_calls_durationm: decorated_invoice.decorated_terminated_calls_duration_kolon,
          i_term_calls_duration_dec: decorated_invoice.decorated_terminated_calls_duration_dec,
          i_term_calls_duration: invoice.terminated_calls_duration,
          i_term_successful_calls_count: invoice.terminated_successful_calls_count,

          i_srv_spent: invoice.services_amount_spent,
          i_srv_earned: invoice.services_amount_earned,
          i_srv_spent_d: decorated_invoice.decorated_services_amount_spent,
          i_srv_earned_d: decorated_invoice.decorated_services_amount_earned,
          t_src_transactions_count: invoice.service_transactions_count
        }
      end

      def generate_odf_document(odf_path)
        originated_destinations = InvoiceOriginatedDestinationDecorator.decorate_collection(
          invoice.originated_destinations.for_invoice.order('dst_prefix').to_a
        )
        originated_destinations_succ = InvoiceOriginatedDestinationDecorator.decorate_collection(
          invoice.originated_destinations.for_invoice_succ.order('dst_prefix').to_a
        )

        terminated_destinations = InvoiceTerminatedDestinationDecorator.decorate_collection(
          invoice.terminated_destinations.for_invoice.order('dst_prefix').to_a
        )
        terminated_destinations_succ = InvoiceTerminatedDestinationDecorator.decorate_collection(
          invoice.terminated_destinations.for_invoice_succ.order('dst_prefix').to_a
        )

        originated_networks = InvoiceOriginatedNetworkDecorator.decorate_collection(
          invoice.originated_networks.for_invoice.order('country_id, network_id').to_a
        )
        originated_networks_succ = InvoiceOriginatedNetworkDecorator.decorate_collection(
          invoice.originated_networks.for_invoice_succ.order('country_id, network_id').to_a
        )

        terminated_networks = InvoiceTerminatedNetworkDecorator.decorate_collection(
          invoice.terminated_networks.for_invoice.order('country_id, network_id').to_a
        )

        terminated_networks_succ = InvoiceTerminatedNetworkDecorator.decorate_collection(
          invoice.terminated_networks.for_invoice_succ.order('country_id, network_id').to_a
        )

        services = InvoiceServiceDataDecorator.decorate_collection(
          invoice.service_data.for_invoice.to_a
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
          r.add_table('INV_ORIG_DST_SUCC_TABLE', originated_destinations_succ, header: true, footer: true) do |t|
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
          r.add_table('INV_TERM_DST_SUCC_TABLE', terminated_destinations_succ, header: true, footer: true) do |t|
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
          r.add_table('INV_ORIG_NETWORKS_SUCC_TABLE', originated_networks_succ, header: true, footer: true) do |t|
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
          r.add_table('INV_TERM_NETWORKS_SUCC_TABLE', terminated_networks_succ, header: true, footer: true) do |t|
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
          r.add_table('INV_SRV_DATA_TABLE', services, header: true, footer: true) do |t|
            t.add_column(:service) { |field| field.service.try(:name) }
            t.add_column(:transactions_count)
            t.add_column(:amount)
            t.add_column(:amount_decorated, &:decorated_amount)
          end
        end.generate(odf_path) # New ODFReport constructor return data, not a file name
      end

      def convert_to_pdf(odf_path, pdf_path)
        unless YetiConfig.invoice&.pdf_converter&.present?
          return
        end

        pdf_command = "#{YetiConfig.invoice&.pdf_converter} #{Shellwords.escape(odf_path)} #{Shellwords.escape(pdf_path)}"

        _stdout, _stderr, status = Open3.capture3(pdf_command)
        status
      end

      def save_read_file(file_path)
        File.read(file_path)
      rescue StandardError => e
        logger.error { e.message }
        logger.error { e.backtrace.join("\n") }
        capture_error(e, extra: { service_class: self.class.name, file_path: file_path })
        nil
      end

      def with_tempfiles
        Tempfile.create(["invoice-#{invoice.id}", '.odt'], YetiConfig.tmpdir, binmode: true) do |odf_file|
          Tempfile.create(["invoice-#{invoice.id}", '.pdf'], YetiConfig.tmpdir, binmode: true) do |pdf_file|
            yield(odf_file, pdf_file)
          end
        end
      end
    end
  end
end
