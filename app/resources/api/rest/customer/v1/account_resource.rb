class Api::Rest::Customer::V1::AccountResource < BaseResource
  model_name 'Account'

  key_type :uuid
  primary_key :uuid

  attributes :name,
             :balance, :min_balance, :max_balance,
             :origination_capacity

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
