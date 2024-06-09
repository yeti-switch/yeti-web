# frozen_string_literal: true

class Api::Rest::Customer::V1::InvoiceResource < Api::Rest::Customer::V1::BaseResource
  model_name 'Billing::Invoice'

  attributes :reference,
             :start_date,
             :end_date,
             :has_pdf

  attribute :amount_spent

  attribute :originated_amount_spent
  attribute :originated_calls_count
  attribute :originated_successful_calls_count
  attribute :originated_calls_duration
  attribute :originated_billing_duration
  attribute :originated_first_call_at, delegate: :first_originated_call_at
  attribute :originated_last_call_at, delegate: :last_originated_call_at

  attribute :terminated_amount_spent
  attribute :terminated_calls_count
  attribute :terminated_successful_calls_count
  attribute :terminated_calls_duration
  attribute :terminated_billing_duration
  attribute :terminated_first_call_at, delegate: :first_terminated_call_at
  attribute :terminated_last_call_at, delegate: :last_terminated_call_at

  attribute :services_amount_spent
  attribute :service_transactions_count

  has_one :account, foreign_key_on: :related

  ransack_filter :reference, type: :string
  ransack_filter :start_date, type: :datetime
  ransack_filter :end_date, type: :datetime
  ransack_filter :amount_spent, type: :number

  ransack_filter :originated_amount_spent, type: :number
  ransack_filter :originated_calls_count, type: :number
  ransack_filter :originated_successful_calls_count, type: :number
  ransack_filter :originated_calls_duration, type: :number
  ransack_filter :originated_billing_duration, type: :number
  ransack_filter :originated_first_call_at, type: :datetime, column: :first_originated_call_at
  ransack_filter :originated_last_call_at, type: :datetime, column: :last_originated_call_at

  ransack_filter :terminated_amount_spent, type: :number
  ransack_filter :terminated_calls_count, type: :number
  ransack_filter :terminated_successful_calls_count, type: :number
  ransack_filter :terminated_calls_duration, type: :number
  ransack_filter :terminated_billing_duration, type: :number
  ransack_filter :terminated_first_call_at, type: :datetime, column: :first_terminated_call_at
  ransack_filter :terminated_last_call_at, type: :datetime, column: :last_terminated_call_at

  ransack_filter :services_amount_spent, type: :number
  ransack_filter :service_transactions_count, type: :number

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
