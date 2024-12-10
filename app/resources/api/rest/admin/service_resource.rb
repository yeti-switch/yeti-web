# frozen_string_literal: true

class Api::Rest::Admin::ServiceResource < ::BaseResource
  model_name 'Billing::Service'
  paginator :paged

  attribute :name
  attribute :variables
  attribute :state
  attribute :initial_price
  attribute :renew_price
  attribute :created_at
  attribute :renew_at
  attribute :renew_period
  attribute :uuid

  has_one :account, class_name: 'Account', always_include_linkage_data: true
  has_one :service_type, class_name: 'ServiceType', foreign_key: :type_id, relation_name: :type
  has_many :transactions, class_name: 'Transaction', foreign_key_on: :related

  ransack_filter :account_id, type: :foreign_key
  ransack_filter :type_id, type: :foreign_key

  ransack_filter :uuid, type: :uuid
  ransack_filter :created_at, type: :datetime
  ransack_filter :name, type: :string
  ransack_filter :initial_price, type: :number
  ransack_filter :renew_price, type: :number
  ransack_filter :renew_at, type: :datetime
  ransack_filter :renew_period,
                 type: :enum,
                 column: :renew_period_id,
                 collection: Billing::Service::RENEW_PERIODS.values

  def service_type_id=(value)
    _model.type_id = value
  end

  def renew_period=(value)
    _model.renew_period_id = Billing::Service::RENEW_PERIODS.key(value) || -1
  end

  def replace_model_error_keys
    { type: :service_type }
  end

  def self.sortable_fields(_ctx = nil)
    %i[id name initial_price renew_price created_at renew_at renew_period]
  end

  def self.creatable_fields(_ctx = nil)
    %i[account service_type name initial_price renew_price renew_at renew_period variables]
  end

  def self.updatable_fields(_ctx = nil)
    %i[name renew_price variables]
  end
end
