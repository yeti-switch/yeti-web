# frozen_string_literal: true

class Api::Rest::Customer::V1::AccountResource < Api::Rest::Customer::V1::BaseResource
  model_name 'Account'

  attributes :name,
             :balance, :min_balance, :max_balance,
             :destination_rate_limit,
             :origination_capacity, :termination_capacity, :total_capacity

  ransack_filter :name, type: :string
  ransack_filter :balance, type: :number
  ransack_filter :min_balance, type: :number
  ransack_filter :max_balance, type: :number
  ransack_filter :balance_low_threshold, type: :number
  ransack_filter :balance_high_threshold, type: :number
  ransack_filter :destination_rate_limit, type: :number
  ransack_filter :max_call_duration, type: :number
  ransack_filter :external_id, type: :number
  ransack_filter :uuid, type: :uuid
  ransack_filter :origination_capacity, type: :number
  ransack_filter :termination_capacity, type: :number
  ransack_filter :total_capacity, type: :number

  def self.apply_allowed_accounts(records, options)
    context = options[:context]
    scope = records.where(contractor_id: context[:customer_id])
    scope = scope.where(id: context[:allowed_account_ids]) if context[:allowed_account_ids].present?
    scope
  end
end
