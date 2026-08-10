# frozen_string_literal: true

class Api::Rest::Admin::InvoiceTemplateResource < ::BaseResource
  model_name 'Billing::InvoiceTemplate'

  attributes :name, :html_template, :filename_template

  paginator :paged

  ransack_filter :name, type: :string
end
