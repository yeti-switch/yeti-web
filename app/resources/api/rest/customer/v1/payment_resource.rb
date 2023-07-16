# frozen_string_literal: true

class Api::Rest::Customer::V1::PaymentResource < Api::Rest::Customer::V1::BaseResource
  model_name 'Payment'

  attributes :amount,
             :notes,
             :status,
             :created_at

  has_one :account, foreign_key_on: :related

  ransack_filter :uuid, type: :uuid
  ransack_filter :notes, type: :string
  ransack_filter :amount, type: :number
  ransack_filter :created_at, type: :datetime
  association_uuid_filter :account_id, class_name: 'Account'
  ransack_filter :status, type: :enum, collection: Payment::CONST::STATUS_IDS.values

  def self.apply_allowed_accounts(records, options)
    context = options[:context]
    records = records.ransack(account_contractor_id_eq: context[:customer_id]).result
    records = records.where(account_id: context[:allowed_account_ids]) if context[:allowed_account_ids].present?
    records
  end

  def self.sortable_fields(_context)
    %i[amount notes created_at]
  end
end
