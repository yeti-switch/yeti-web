# frozen_string_literal: true

class Api::Rest::Customer::V1::AccountResource < BaseResource
  model_name 'Account'

  key_type :uuid
  primary_key :uuid
  paginator :paged

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

  def self.records(options = {})
    apply_allowed_accounts(super(options), options)
  end

  def self.apply_allowed_accounts(_records, options)
    context = options[:context]
    scope = _records.where(contractor_id: context[:customer_id])
    scope = scope.where(id: context[:allowed_account_ids]) if context[:allowed_account_ids].present?
    scope
  end
end
