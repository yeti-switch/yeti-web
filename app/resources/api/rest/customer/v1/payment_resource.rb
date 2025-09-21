# frozen_string_literal: true

class Api::Rest::Customer::V1::PaymentResource < Api::Rest::Customer::V1::BaseResource
  model_name 'Payment'

  attributes :amount,
             :notes,
             :status,
             :type_name,
             :created_at,
             :balance_before_payment

  has_one :account, foreign_key_on: :related

  def self.default_sort
    [{ field: 'created_at', direction: :desc }]
  end

  ransack_filter :uuid, type: :uuid
  ransack_filter :notes, type: :string
  ransack_filter :amount, type: :number
  ransack_filter :created_at, type: :datetime
  association_uuid_filter :account_id, class_name: 'Account'
  ransack_filter :status, type: :enum, collection: Payment::CONST::STATUS_IDS.values
  ransack_filter :type_name, type: :enum, collection: Payment::CONST::TYPE_IDS.values

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
