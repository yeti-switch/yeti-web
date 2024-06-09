# frozen_string_literal: true

class Api::Rest::Admin::Billing::InvoiceServiceDatumResource < ::BaseResource
  model_name 'Billing::InvoiceServiceData'
  paginator :paged

  attribute :amount
  attribute :transactions_count
  attribute :spent

  has_one :invoice, class_name: 'Invoice', foreign_key_on: :related
  has_one :service, class_name: 'Service', foreign_key_on: :related

  ransack_filter :amount, type: :number
  ransack_filter :transactions_count, type: :number
  ransack_filter :spent, type: :boolean

  ransack_filter :invoice_id, type: :foreign_key

  ransack_filter :invoice_account_id,
                 type: :foreign_key,
                 column: :invoice_id,
                 verify: ->(values) { ::Billing::Invoice.where(account_id: values).pluck(:id) }

  ransack_filter :service_id, type: :foreign_key

  def pdf_url
    nil
  end

  def odt_url
    nil
  end
end
