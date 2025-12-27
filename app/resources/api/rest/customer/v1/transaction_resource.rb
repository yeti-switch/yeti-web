# frozen_string_literal: true

class Api::Rest::Customer::V1::TransactionResource < Api::Rest::Customer::V1::BaseResource
  model_name 'Billing::Transaction'

  attribute :description
  attribute :amount
  attribute :created_at

  has_one :account, class_name: 'Account', foreign_key_on: :related
  has_one :service, class_name: 'Service', foreign_key_on: :related

  def self.default_sort
    [{ field: 'created_at', direction: :desc }]
  end

  ransack_filter :created_at, type: :datetime
  association_uuid_filter :account_id, class_name: 'Account'
  association_uuid_filter :service_id, class_name: 'Billing::Service'
  ransack_filter :amount, type: :number
  ransack_filter :description, type: :string

  def self.sortable_fields(_ctx = nil)
    %i[id created_at service_id amount]
  end

  def self.apply_allowed_accounts(records, options)
    context = options[:context]
    if context[:allowed_account_ids].present?
      records.where(account_id: context[:allowed_account_ids])
    else
      records.joins(:account).where(accounts: { contractor_id: context[:customer_id] })
    end
  end
end
