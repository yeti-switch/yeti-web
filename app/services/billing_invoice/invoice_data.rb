# frozen_string_literal: true

module BillingInvoice
  # Builds the JSON-serialisable payload sent to the yeti-pdf render service.
  #
  # Values are RAW (numbers, integer seconds, ISO-8601 timestamps): all
  # formatting (money, durations, dates) is done template-side by yeti-pdf's
  # pongo2 filters, mirroring what the ODT decorators used to do. The shape is
  # nested so templates read naturally, e.g. {{ account.name }},
  # {{ invoice.amount_total|money }}, {{ d.calls_duration|duration:"colon" }}.
  class InvoiceData < ApplicationService
    parameter :invoice, required: true

    def call
      {
        account: account_data,
        contractor: contractor_data,
        invoice: invoice_data,
        originated_destinations: destinations(invoice.originated_destinations.for_invoice.order('dst_prefix')),
        originated_destinations_succ: destinations(invoice.originated_destinations.for_invoice_succ.order('dst_prefix')),
        terminated_destinations: destinations(invoice.terminated_destinations.for_invoice.order('dst_prefix')),
        terminated_destinations_succ: destinations(invoice.terminated_destinations.for_invoice_succ.order('dst_prefix')),
        originated_networks: networks(invoice.originated_networks.for_invoice.order('country_id, network_id')),
        originated_networks_succ: networks(invoice.originated_networks.for_invoice_succ.order('country_id, network_id')),
        terminated_networks: networks(invoice.terminated_networks.for_invoice.order('country_id, network_id')),
        terminated_networks_succ: networks(invoice.terminated_networks.for_invoice_succ.order('country_id, network_id')),
        service_data: services(invoice.service_data.for_invoice)
      }
    end

    private

    def account_data
      account = invoice.account
      {
        id: account.id,
        name: account.name,
        balance: num(account.balance),
        min_balance: num(account.min_balance),
        max_balance: num(account.max_balance),
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
        amount_total: num(invoice.amount_total),
        amount_spent: num(invoice.amount_spent),
        amount_earned: num(invoice.amount_earned),
        originated: {
          amount_spent: num(invoice.originated_amount_spent),
          amount_earned: num(invoice.originated_amount_earned),
          calls_count: int(invoice.originated_calls_count),
          successful_calls_count: int(invoice.originated_successful_calls_count),
          calls_duration: num(invoice.originated_calls_duration),
          first_call_at: time(invoice.first_originated_call_at),
          last_call_at: time(invoice.last_originated_call_at)
        },
        terminated: {
          amount_spent: num(invoice.terminated_amount_spent),
          amount_earned: num(invoice.terminated_amount_earned),
          calls_count: int(invoice.terminated_calls_count),
          successful_calls_count: int(invoice.terminated_successful_calls_count),
          calls_duration: num(invoice.terminated_calls_duration),
          first_call_at: time(invoice.first_terminated_call_at),
          last_call_at: time(invoice.last_terminated_call_at)
        },
        services: {
          amount_spent: num(invoice.services_amount_spent),
          amount_earned: num(invoice.services_amount_earned),
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
          rate: num(row.rate),
          calls_count: int(row.calls_count),
          successful_calls_count: int(row.successful_calls_count),
          calls_duration: num(row.calls_duration),
          amount: num(row.amount),
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
          rate: num(row.rate),
          calls_count: int(row.calls_count),
          successful_calls_count: int(row.successful_calls_count),
          calls_duration: num(row.calls_duration),
          amount: num(row.amount),
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
          amount: num(row.amount)
        }
      end
    end

    # Numeric (money/rate/duration) -> Float so it serialises as a JSON number
    # (BigDecimal would serialise as a string and break the template filters).
    def num(value)
      value&.to_f
    end

    def int(value)
      value&.to_i
    end

    def time(value)
      value&.iso8601
    end
  end
end
