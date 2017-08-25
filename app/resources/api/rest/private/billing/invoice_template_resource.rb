class Api::Rest::Private::Billing::InvoiceTemplateResource < ::BaseResource
  model_name 'Billing::InvoiceTemplate'

  attributes :name, :filename
end
