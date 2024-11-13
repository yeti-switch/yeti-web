# frozen_string_literal: true

class Api::Rest::Admin::Billing::InvoiceTemplateResource < ::BaseResource
  model_name 'Billing::InvoiceTemplate'

  attributes :name, :filename

  paginator :paged

  ransack_filter :name, type: :string
  ransack_filter :filename, type: :string
end
