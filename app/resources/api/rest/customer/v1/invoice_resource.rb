# frozen_string_literal: true

class Api::Rest::Customer::V1::InvoiceResource < Api::Rest::Customer::V1::BaseResource
  model_name 'Billing::Invoice'

  attributes :reference,
             :start_date,
             :end_date,
             :has_pdf

  attribute :amount, delegate: :terminated_amount
  attribute :calls_count, delegate: :terminated_calls_count
  attribute :successful_calls_count, delegate: :terminated_successful_calls_count
  attribute :calls_duration, delegate: :terminated_calls_duration
  attribute :billing_duration, delegate: :terminated_billing_duration
  attribute :first_call_at, delegate: :first_terminated_call_at
  attribute :last_call_at, delegate: :last_terminated_call_at

  has_one :account, foreign_key_on: :related

  ransack_filter :reference, type: :string
  ransack_filter :start_date, type: :datetime
  ransack_filter :end_date, type: :datetime
  ransack_filter :amount, type: :number, column: :terminated_amount
  ransack_filter :calls_count, type: :number, column: :terminated_calls_count
  ransack_filter :successful_calls_count, type: :number, column: :terminated_successful_calls_count
  ransack_filter :calls_duration, type: :number, column: :terminated_calls_duration
  ransack_filter :billing_duration, type: :number, column: :terminated_billing_duration
  ransack_filter :first_call_at, type: :datetime, column: :first_terminated_call_at
  ransack_filter :last_call_at, type: :datetime, column: :last_terminated_call_at

  association_uuid_filter :account_id, class_name: 'Account'

  def has_pdf
    _model.invoice_document&.pdf_data.present?
  end

  def self.apply_allowed_accounts(records, options)
    context = options[:context]
    scope = records.approved
                   .preload(:invoice_document)
                   .where(contractor_id: context[:customer_id])
    scope = scope.where(account_id: context[:allowed_account_ids]) if context[:allowed_account_ids].present?
    scope
  end
end
