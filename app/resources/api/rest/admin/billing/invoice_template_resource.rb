class Api::Rest::Admin::Billing::InvoiceTemplateResource < ::BaseResource
  model_name 'Billing::InvoiceTemplate'

  attributes :name, :filename
end
