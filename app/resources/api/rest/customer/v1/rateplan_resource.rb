# frozen_string_literal: true

class Api::Rest::Customer::V1::RateplanResource < Api::Rest::Customer::V1::BaseResource
  model_name 'Routing::Rateplan'

  attributes :name

  ransack_filter :name, type: :string

  def self.apply_allowed_accounts(records, options)
    context = options[:context]
    scope = records.where_customer(context[:customer_id])
    scope = scope.where_account(context[:allowed_account_ids]) if context[:allowed_account_ids].present?
    scope
  end
end
