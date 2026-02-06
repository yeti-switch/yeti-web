# frozen_string_literal: true

class Api::Rest::Admin::TransactionResource < ::BaseResource
  model_name 'Billing::Transaction'
  paginator :paged

  attribute :description
  attribute :amount
  attribute :created_at
  attribute :uuid

  has_one :account, class_name: 'Account', always_include_linkage_data: true
  has_one :service, class_name: 'Service', relation_name: :type, always_include_linkage_data: true

  ransack_filter :account_id, type: :foreign_key
  ransack_filter :service_id, type: :foreign_key

  ransack_filter :uuid, type: :uuid
  ransack_filter :created_at, type: :datetime
  ransack_filter :amount, type: :number
  ransack_filter :description, type: :string

  def self.sortable_fields(_ctx = nil)
    %i[id created_at account_id service_id amount]
  end

  def self.creatable_fields(_ctx = nil)
    %i[amount description account service]
  end
end
