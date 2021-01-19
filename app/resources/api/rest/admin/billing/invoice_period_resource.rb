# frozen_string_literal: true

class Api::Rest::Admin::Billing::InvoicePeriodResource < ::BaseResource
  model_name 'Billing::InvoicePeriod'

  attributes :name

  paginator :paged

  filter :name
end
