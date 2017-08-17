class Api::Rest::Private::Billing::InvoiceTemplateResource < ::BaseResource
  immutable
  model_name 'Billing::InvoiceTemplate'
  type 'billing/invoice_templates'

  attributes :name
end
