# frozen_string_literal: true

module BillingInvoice
  class Fill < ApplicationService
    parameter :invoice, required: true

    def call
      AdvisoryLock::Cdr.with_lock(:invoice, id: invoice.account_id) do
        invoice.reload
        validate!

        invoice.vendor_invoice ? generate_vendor_data : generate_customer_data
        update_totals
        create_invoice_docs
      end
    end

    private

    def validate!
      raise Error, 'invoice already filled' if invoice.state_id != Billing::InvoiceState::NEW
    end

    def generate_vendor_data
      SqlCaller::Cdr.execute(
          "INSERT INTO billing.invoice_destinations(
            dst_prefix, country_id, network_id, rate,
            calls_count,
            successful_calls_count,
            calls_duration,
            billing_duration,
            amount,
            invoice_id,
            first_call_at,
            first_successful_call_at,
            last_call_at,
            last_successful_call_at
          ) SELECT
            dialpeer_prefix, dst_country_id, dst_network_id, dialpeer_next_rate,
            COUNT(id),  -- calls count
            COUNT(NULLIF(success,false)),  -- successful_calls_count
            SUM(duration), -- calls_duration
            SUM(vendor_duration), -- billing_duration
            SUM(vendor_price), -- amount
            ?, -- invoice_id
            MIN(time_start), -- first_call_at
            MIN(CASE success WHEN true THEN time_start ELSE NULL END), -- first_successful_call_at
            MAX(time_start), -- last_call_at
            MAX(CASE success WHEN true THEN time_start ELSE NULL END) -- last_successful_call_at
          FROM (
            SELECT *
            FROM cdr.cdr
            WHERE
              vendor_acc_id =? AND
              time_start>=? AND
              time_start<?
          ) invoice_data
          GROUP BY dialpeer_prefix, dst_country_id, dst_network_id, dialpeer_next_rate",
          invoice.id,
          invoice.account_id,
          invoice.start_date,
          invoice.end_date
        )

      SqlCaller::Cdr.execute(
          "INSERT INTO billing.invoice_networks(
            country_id, network_id, rate,
            calls_count,
            successful_calls_count,
            calls_duration,
            billing_duration,
            amount,
            invoice_id,
            first_call_at,
            first_successful_call_at,
            last_call_at,
            last_successful_call_at
          ) SELECT
            country_id, network_id, rate,
            SUM(calls_count),
            SUM(successful_calls_count),
            SUM(calls_duration),
            SUM(billing_duration),
            SUM(amount),
            ?, -- invoice_id
            MIN(first_call_at),
            MIN(first_successful_call_at),
            MAX(last_call_at),
            MAX(last_successful_call_at)
          FROM billing.invoice_destinations
          WHERE invoice_id=?
          GROUP BY country_id, network_id, rate",
          invoice.id,
          invoice.id
        )
    end

    def generate_customer_data
      SqlCaller::Cdr.execute(
          "INSERT INTO billing.invoice_destinations(
            dst_prefix, country_id, network_id, rate,
            calls_count,
            successful_calls_count,
            calls_duration,
            billing_duration,
            amount,
            invoice_id,
            first_call_at,
            first_successful_call_at,
            last_call_at,
            last_successful_call_at
          ) SELECT
            destination_prefix, dst_country_id, dst_network_id, destination_next_rate,
            COUNT(NULLIF(is_last_cdr,false)), -- calls_count
            COUNT(NULLIF((success AND is_last_cdr),false)),  -- successful_calls_count
            SUM(duration), -- calls_duration
            SUM(customer_duration), -- billing_duration
            SUM(customer_price), -- amount
            ?, -- invoice_id
            MIN(time_start), -- first_call_at
            MIN(CASE success WHEN true THEN time_start ELSE NULL END), -- first_successful_call_at
            MAX(time_start), -- last_call_at
            MAX(CASE success WHEN true THEN time_start ELSE NULL END) -- last_successful_call_at
          FROM (
            SELECT *
            FROM cdr.cdr
            WHERE
              customer_acc_id =? AND
              time_start >=? AND
              time_start < ?
          ) invoice_data
          GROUP BY destination_prefix, dst_country_id, dst_network_id, destination_next_rate",
          invoice.id,
          invoice.account_id,
          invoice.start_date,
          invoice.end_date
        )

      SqlCaller::Cdr.execute(
          "INSERT INTO billing.invoice_networks(
            country_id, network_id, rate,
            calls_count,
            successful_calls_count,
            calls_duration,
            billing_duration,
            amount,
            invoice_id,
            first_call_at,
            first_successful_call_at,
            last_call_at,
            last_successful_call_at
          ) SELECT
            country_id, network_id, rate,
            SUM(calls_count),
            SUM(successful_calls_count),
            SUM(calls_duration),
            SUM(billing_duration),
            SUM(amount),
            ?, -- invoice_id
            MIN(first_call_at),
            MIN(first_successful_call_at),
            MAX(last_call_at),
            MAX(last_successful_call_at)
          FROM billing.invoice_destinations
          WHERE invoice_id=?
          GROUP BY country_id, network_id, rate",
          invoice.id,
          invoice.id
        )
    end

    def update_totals
      data = invoice.destinations.summary

      invoice.update!(
          state_id: Billing::InvoiceState::PENDING,
          amount: data.amount,
          calls_count: data.calls_count,
          successful_calls_count: data.successful_calls_count,
          calls_duration: data.calls_duration,
          billing_duration: data.billing_duration,
          first_call_at: data.first_call_at,
          first_successful_call_at: data.first_successful_call_at,
          last_call_at: data.last_call_at,
          last_successful_call_at: data.last_successful_call_at
        )
    end

    def create_invoice_docs
      BillingInvoice::GenerateDocument.call(invoice: invoice)
    rescue BillingInvoice::GenerateDocument::TemplateUndefined => e
      Rails.logger.info { "#{e.class}: #{e.message}" }
      capture_error(e)
    end
  end
end
