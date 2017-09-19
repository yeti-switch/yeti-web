class Api::Rest::Customer::V1::RateplanResource < BaseResource
  model_name 'Rateplan'

  key_type :uuid
  primary_key :uuid

  attributes :name

  def self.records(options = {})
    apply_allowed_accounts(super(options), options)
  end

  def self.apply_allowed_accounts(_records, options)
    context = options[:context]
    scope = _records.where_customer(context[:customer_id])
    scope = scope.where_account(context[:allowed_account_ids]) if context[:allowed_account_ids].present?
    scope
  end
end
