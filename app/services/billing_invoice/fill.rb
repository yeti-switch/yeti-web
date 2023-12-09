# frozen_string_literal: true

module BillingInvoice
  class Fill < ApplicationService
    parameter :invoice, required: true

    def call
      AdvisoryLock::Cdr.with_lock(:invoice, id: invoice.account_id) do
        invoice.reload
        validate!

        generate_originated_data
        generate_terminated_data
        update_totals
        create_invoice_docs
      end
    end

    private

    def validate!
      raise Error, 'invoice already filled' if invoice.state_id != Billing::InvoiceState::NEW
    end

    def generate_originated_data
      # traffic originated by account as "customer"
      SqlCaller::Cdr.execute(
          "INSERT INTO billing.invoice_originated_destinations(
            dst_prefix, country_id, network_id, rate,
            calls_count,
            successful_calls_count,
            calls_duration,
            billing_duration,
            amount,
            invoice_id,
            first_call_at,
            last_call_at
          ) SELECT
            destination_prefix, dst_country_id, dst_network_id, destination_next_rate,
            COUNT(id),  -- calls count
            COUNT(NULLIF(success,false)),  -- successful_calls_count
            SUM(duration), -- calls_duration
            SUM(customer_duration), -- billing_duration
            SUM(customer_price), -- amount
            ?, -- invoice_id
            MIN(time_start), -- first_call_at
            MAX(time_start) -- last_call_at
          FROM cdr.cdr
          WHERE
            customer_acc_id =? AND
            is_last_cdr AND
            time_start>=? AND
            time_start<?
          GROUP BY
            destination_prefix, dst_country_id, dst_network_id, destination_next_rate",
          invoice.id,
          invoice.account_id,
          invoice.start_date,
          invoice.end_date
        )

      SqlCaller::Cdr.execute(
          "INSERT INTO billing.invoice_originated_networks(
            country_id, network_id, rate,
            calls_count,
            successful_calls_count,
            calls_duration,
            billing_duration,
            amount,
            invoice_id,
            first_call_at,
            last_call_at
          ) SELECT
            country_id, network_id, rate,
            SUM(calls_count),
            SUM(successful_calls_count),
            SUM(calls_duration),
            SUM(billing_duration),
            SUM(amount),
            ?, -- invoice_id
            MIN(first_call_at),
            MAX(last_call_at)
          FROM billing.invoice_originated_destinations
          WHERE invoice_id=?
          GROUP BY
            country_id, network_id, rate",
          invoice.id,
          invoice.id
        )
    end

    def generate_terminated_data
      # traffic terminated to account as "vendor"
      SqlCaller::Cdr.execute(
          "INSERT INTO billing.invoice_terminated_destinations(
            dst_prefix, country_id, network_id, rate,
            calls_count,
            successful_calls_count,
            calls_duration,
            billing_duration,
            amount,
            invoice_id,
            first_call_at,
            last_call_at
          ) SELECT
            dialpeer_prefix, dst_country_id, dst_network_id, dialpeer_next_rate,
            COUNT(*), -- calls_count
            COUNT(NULLIF((success),false)),  -- successful_calls_count
            SUM(duration), -- calls_duration
            SUM(vendor_duration), -- billing_duration
            SUM(vendor_price), -- amount
            ?, -- invoice_id
            MIN(time_start), -- first_call_at
            MAX(time_start) -- last_call_at
          FROM cdr.cdr
          WHERE
            vendor_acc_id =? AND
            time_start >=? AND
            time_start < ?
          GROUP BY
            dialpeer_prefix, dst_country_id, dst_network_id, dialpeer_next_rate",
          invoice.id,
          invoice.account_id,
          invoice.start_date,
          invoice.end_date
        )

      SqlCaller::Cdr.execute(
          "INSERT INTO billing.invoice_terminated_networks(
            country_id, network_id, rate,
            calls_count,
            successful_calls_count,
            calls_duration,
            billing_duration,
            amount,
            invoice_id,
            first_call_at,
            last_call_at
          ) SELECT
            country_id, network_id, rate,
            SUM(calls_count),
            SUM(successful_calls_count),
            SUM(calls_duration),
            SUM(billing_duration),
            SUM(amount),
            ?, -- invoice_id
            MIN(first_call_at),
            MAX(last_call_at)
          FROM billing.invoice_terminated_destinations
          WHERE invoice_id=?
          GROUP BY
            country_id, network_id, rate",
          invoice.id,
          invoice.id
        )
    end

    def update_totals
      originated_data = invoice.originated_destinations.summary
      terminated_data = invoice.terminated_destinations.summary

      invoice.update!(
          state_id: Billing::InvoiceState::PENDING,

          originated_amount: originated_data.amount,
          originated_calls_count: originated_data.calls_count,
          originated_successful_calls_count: originated_data.successful_calls_count,
          originated_calls_duration: originated_data.calls_duration,
          originated_billing_duration: originated_data.billing_duration,
          first_originated_call_at: originated_data.first_call_at,
          last_originated_call_at: originated_data.last_call_at,

          terminated_amount: terminated_data.amount,
          terminated_calls_count: terminated_data.calls_count,
          terminated_successful_calls_count: terminated_data.successful_calls_count,
          terminated_calls_duration: terminated_data.calls_duration,
          terminated_billing_duration: terminated_data.billing_duration,
          first_terminated_call_at: terminated_data.first_call_at,
          last_terminated_call_at: terminated_data.last_call_at
        )
    end

    def create_invoice_docs
      BillingInvoice::GenerateDocument.call(invoice: invoice)
    rescue BillingInvoice::GenerateDocument::TemplateUndefined => e
      Rails.logger.info { "#{e.class}: #{e.message}" }
    end
  end
end
