class Api::Rest::Private::Billing::InvoicePeriodResource < ::BaseResource
  immutable
  model_name 'Billing::InvoicePeriod'
  type 'billing/invoice_periods'

  attributes :name
end
