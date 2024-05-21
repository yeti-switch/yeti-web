# frozen_string_literal: true

class Api::Rest::Admin::Billing::TransactionResource < ::BaseResource
  model_name 'Billing::Transaction'
  paginator :paged
  immutable

  attribute :description
  attribute :amount
  attribute :created_at
  attribute :uuid

  has_one :account, class_name: 'Account', foreign_key_on: :related
  has_one :service, class_name: 'Service', relation_name: :type, foreign_key_on: :related

  ransack_filter :uuid, type: :uuid
  ransack_filter :created_at, type: :datetime
  ransack_filter :account_id, type: :foreign_key
  ransack_filter :service_id, type: :foreign_key
  ransack_filter :amount, type: :number
  ransack_filter :description, type: :string

  def self.sortable_fields(_ctx = nil)
    %i[id created_at account_id service_id amount]
  end
end
