# frozen_string_literal: true

class Api::Rest::Customer::V1::ServiceResource < Api::Rest::Customer::V1::BaseResource
  model_name 'Billing::Service'
  immutable

  attribute :name
  attribute :state
  attribute :initial_price
  attribute :renew_price
  attribute :created_at
  attribute :renew_at
  attribute :renew_period
  attribute :service_type

  has_one :account, class_name: 'Account', foreign_key_on: :related
  has_many :transactions, class_name: 'Transaction', foreign_key_on: :related

  ransack_filter :created_at, type: :datetime
  ransack_filter :name, type: :string
  association_uuid_filter :account_id, class_name: 'Account'
  ransack_filter :initial_price, type: :number
  ransack_filter :renew_price, type: :number
  ransack_filter :renew_at, type: :datetime
  ransack_filter :renew_period,
                 type: :enum,
                 column: :renew_period_id,
                 collection: Billing::Service::RENEW_PERIODS.values

  def service_type
    _model.type.name
  end

  def self.sortable_fields(_ctx = nil)
    %i[id name initial_price renew_price created_at renew_at renew_period]
  end

  def self.required_model_includes(_ctx = nil)
    [:type]
  end
end
