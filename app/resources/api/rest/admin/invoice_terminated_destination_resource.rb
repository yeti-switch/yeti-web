# frozen_string_literal: true

class Api::Rest::Admin::InvoiceTerminatedDestinationResource < ::BaseResource
  model_name 'Billing::InvoiceTerminatedDestination'
  paginator :paged

  attribute :amount
  attribute :billing_duration
  attribute :calls_count
  attribute :calls_duration
  attribute :dst_prefix
  attribute :first_call_at
  attribute :last_call_at
  attribute :rate
  attribute :spent
  attribute :successful_calls_count

  has_one :invoice, class_name: 'Invoice', foreign_key_on: :related
  has_one :country, class_name: 'Country', foreign_key_on: :related
  has_one :network, class_name: 'Network', foreign_key_on: :related

  ransack_filter :amount, type: :number
  ransack_filter :billing_duration, type: :number
  ransack_filter :calls_count, type: :number
  ransack_filter :calls_duration, type: :number
  ransack_filter :calls_duration, type: :number
  ransack_filter :dst_prefix, type: :string
  ransack_filter :first_call_at, type: :datetime
  ransack_filter :last_call_at, type: :datetime
  ransack_filter :rate, type: :number
  ransack_filter :spent, type: :boolean
  ransack_filter :successful_calls_count, type: :number

  ransack_filter :invoice_id, type: :foreign_key

  ransack_filter :invoice_account_id,
                 type: :foreign_key,
                 column: :invoice_id,
                 verify: ->(values) { ::Billing::Invoice.where(account_id: values).pluck(:id) }

  ransack_filter :country_id, type: :foreign_key
  ransack_filter :network_id, type: :foreign_key

  def pdf_url
    nil
  end

  def odt_url
    nil
  end
end
