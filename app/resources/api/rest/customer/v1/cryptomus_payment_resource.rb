# frozen_string_literal: true

class Api::Rest::Customer::V1::CryptomusPaymentResource < Api::Rest::Customer::V1::BaseResource
  model_name 'CustomerApi::CryptomusPaymentForm'

  attributes :amount,
             :notes,
             :url

  has_one :account, foreign_key_on: :related

  before_create { _model.customer_id = context[:customer_id] }
  before_create { _model.allowed_account_ids = context[:allowed_account_ids] }

  def self.creatable_fields(_ctx = nil)
    %i[amount notes account]
  end

  def fetchable_fields
    %i[url]
  end
end
