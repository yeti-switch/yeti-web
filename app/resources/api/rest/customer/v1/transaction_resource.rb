# frozen_string_literal: true

class Api::Rest::Customer::V1::TransactionResource < Api::Rest::Customer::V1::BaseResource
  model_name 'Billing::Transaction'
  immutable

  attribute :description
  attribute :amount
  attribute :created_at

  has_one :account, class_name: 'Account', foreign_key_on: :related
  has_one :service, class_name: 'Service', relation_name: :type, foreign_key_on: :related

  ransack_filter :created_at, type: :datetime
  association_uuid_filter :account_id, class_name: 'Account'
  ransack_filter :service_id, type: :foreign_key
  ransack_filter :amount, type: :number
  ransack_filter :description, type: :string

  def self.sortable_fields(_ctx = nil)
    %i[id created_at service_id amount]
  end
end
