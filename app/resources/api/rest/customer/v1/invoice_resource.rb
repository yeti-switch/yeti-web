# frozen_string_literal: true

class Api::Rest::Customer::V1::InvoiceResource < BaseResource
  model_name 'Billing::Invoice'

  key_type :uuid
  primary_key :uuid
  paginator :paged

  attributes :reference,
             :start_date,
             :end_date,
             :amount,
             :calls_count,
             :successful_calls_count,
             :calls_duration,
             :billing_duration,
             :first_call_at,
             :last_call_at,
             :first_successful_call_at,
             :last_successful_call_at,
             :has_pdf

  has_one :account

  ransack_filter :reference, type: :string
  ransack_filter :start_date, type: :datetime
  ransack_filter :end_date, type: :datetime
  ransack_filter :amount, type: :number
  ransack_filter :calls_count, type: :number
  ransack_filter :successful_calls_count, type: :number
  ransack_filter :calls_duration, type: :number
  ransack_filter :billing_duration, type: :number
  ransack_filter :first_call_at, type: :datetime
  ransack_filter :last_call_at, type: :datetime
  ransack_filter :first_successful_call_at, type: :datetime
  ransack_filter :last_successful_call_at, type: :datetime

  def has_pdf
    _model.invoice_document&.pdf_data.present?
  end

  def self.records(options = {})
    records = super(options)
    apply_allowed_accounts(records, options)
  end

  def self.apply_allowed_accounts(records, options)
    context = options[:context]
    scope = records.for_customer
                   .approved
                   .preload(:invoice_document)
                   .where(contractor_id: context[:customer_id])
    scope = scope.where(account_id: context[:allowed_account_ids]) if context[:allowed_account_ids].present?
    scope
  end
end
