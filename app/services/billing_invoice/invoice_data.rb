# frozen_string_literal: true

module BillingInvoice
  # Builds the JSON-serialisable payload sent to the yeti-pdf render service.
  #
  # PG numeric/decimal columns are serialised as exact decimal strings (dec) so
  # no precision is lost: yeti-pdf parses JSON numbers as float64, which cannot
  # hold an arbitrary-precision decimal exactly. Integer/bigint columns (ids,
  # counts, durations) are exact in float64, so they stay JSON numbers (int).
  # Timestamps are ISO-8601 strings. Formatting (money, durations, dates) is done
  # template-side by pongo2 filters, which parse the decimal strings as needed;
  # a raw {{ v }} renders the exact value.
  #
  # Because the decimal fields are strings, templates must use `{% if v > 0 %}`
  # (pongo2 coerces) rather than bare `{% if v %}` on them — "0" is truthy.
  class InvoiceData < ApplicationService
    parameter :invoice, required: true

    def call
      {
        account: account_data,
        contractor: contractor_data,
        invoice: invoice_data,
        originated_destinations: destinations(invoice.originated_destinations.for_invoice.order('dst_prefix')),
        terminated_destinations: destinations(invoice.terminated_destinations.for_invoice.order('dst_prefix')),
        originated_networks: networks(invoice.originated_networks.for_invoice.order('country_id, network_id')),
        terminated_networks: networks(invoice.terminated_networks.for_invoice.order('country_id, network_id')),
        service_data: services(invoice.service_data.for_invoice)
      }
    end

    private

    def account_data
      account = invoice.account
      {
        id: account.id,
        name: account.name,
        currency_id: account.currency_id,
        currency: account.currency_name,
        balance: dec(account.balance),
        min_balance: dec(account.min_balance),
        max_balance: dec(account.max_balance),
        invoice_period: invoice.invoice_period&.name
      }
    end

    def contractor_data
      contractor = invoice.contractor
      {
        name: contractor.name,
        address: contractor.address,
        phones: contractor.phones
      }
    end

    def invoice_data
      {
        id: invoice.id,
        reference: invoice.reference,
        created_at: time(invoice.created_at),
        start_date: time(invoice.start_date),
        end_date: time(invoice.end_date),
        amount_total: dec(invoice.amount_total),
        amount_spent: dec(invoice.amount_spent),
        amount_earned: dec(invoice.amount_earned),
        originated: {
          amount_spent: dec(invoice.originated_amount_spent),
          amount_earned: dec(invoice.originated_amount_earned),
          calls_count: int(invoice.originated_calls_count),
          successful_calls_count: int(invoice.originated_successful_calls_count),
          calls_duration: int(invoice.originated_calls_duration),
          first_call_at: time(invoice.first_originated_call_at),
          last_call_at: time(invoice.last_originated_call_at)
        },
        terminated: {
          amount_spent: dec(invoice.terminated_amount_spent),
          amount_earned: dec(invoice.terminated_amount_earned),
          calls_count: int(invoice.terminated_calls_count),
          successful_calls_count: int(invoice.terminated_successful_calls_count),
          calls_duration: int(invoice.terminated_calls_duration),
          first_call_at: time(invoice.first_terminated_call_at),
          last_call_at: time(invoice.last_terminated_call_at)
        },
        services: {
          amount_spent: dec(invoice.services_amount_spent),
          amount_earned: dec(invoice.services_amount_earned),
          transactions_count: int(invoice.service_transactions_count)
        }
      }
    end

    def destinations(scope)
      scope.map do |row|
        {
          prefix: row.dst_prefix,
          country: row.country&.name,
          network: row.network&.name,
          rate: dec(row.rate),
          calls_count: int(row.calls_count),
          successful_calls_count: int(row.successful_calls_count),
          calls_duration: int(row.calls_duration),
          amount: dec(row.amount),
          first_call_at: time(row.first_call_at),
          last_call_at: time(row.last_call_at)
        }
      end
    end

    def networks(scope)
      scope.map do |row|
        {
          country: row.country&.name,
          network: row.network&.name,
          rate: dec(row.rate),
          calls_count: int(row.calls_count),
          successful_calls_count: int(row.successful_calls_count),
          calls_duration: int(row.calls_duration),
          amount: dec(row.amount),
          first_call_at: time(row.first_call_at),
          last_call_at: time(row.last_call_at)
        }
      end
    end

    def services(scope)
      scope.map do |row|
        {
          service: row.service&.name,
          transactions_count: int(row.transactions_count),
          amount: dec(row.amount)
        }
      end
    end

    # Exact decimal string for every PG numeric/decimal value, so no precision
    # is lost converting to float. Formatting filters still work (they parse the
    # string); a raw {{ v }} renders the exact value. Avoid bare `{% if v %}` on
    # these ("0" is a truthy string) — use `{% if v > 0 %}`, which pongo2 coerces.
    def dec(value)
      value&.to_s('F')
    end

    # Integer/bigint columns (counts, durations) as an Integer JSON number —
    # exact in float64, so no need to stringify.
    def int(value)
      value&.to_i
    end

    def time(value)
      value&.iso8601
    end
  end
end
