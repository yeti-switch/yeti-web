class Api::Rest::Customer::V1::RateResource < BaseResource
  model_name 'Routing::Destination'

  key_type :uuid
  primary_key :uuid

  attributes :prefix,
             :initial_rate,
             :initial_interval,
             :next_rate,
             :next_interval,
             :connect_fee,
             :reject_calls,
             :valid_from,
             :valid_till,
             :network_prefix_id

  # has_one :rateplan
  # has_one :account

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
