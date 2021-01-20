# frozen_string_literal: true

class Api::Rest::Admin::Billing::InvoiceTemplateResource < ::BaseResource
  model_name 'Billing::InvoiceTemplate'

  attributes :name, :filename

  paginator :paged

  filter :name
end
