# frozen_string_literal: true
# frozen_string_literal: true

class Api::Rest::Customer::V1::RateResource < Api::Rest::Customer::V1::BaseResource
  model_name 'Routing::Destination'

  attributes :prefix,
             :dst_number_min_length,
             :dst_number_max_length,
             :enabled,
             :reject_calls,
             :initial_rate,
             :initial_interval,
             :next_rate,
             :next_interval,
             :connect_fee,
             :valid_from,
             :valid_till,
             :network_prefix_id

  def self.default_sort
    [{ field: 'prefix', direction: :asc }]
  end

  ransack_filter :prefix, type: :string
  ransack_filter :dst_number_min_length, type: :number
  ransack_filter :dst_number_max_length, type: :number

  ransack_filter :enabled, type: :boolean
  ransack_filter :reject_calls, type: :boolean

  ransack_filter :initial_rate, type: :number
  ransack_filter :next_rate, type: :number
  ransack_filter :initial_interval, type: :number
  ransack_filter :next_interval, type: :number
  ransack_filter :connect_fee, type: :number

  ransack_filter :valid_from, type: :datetime
  ransack_filter :valid_till, type: :datetime
  ransack_filter :uuid, type: :uuid

  filter :rateplan_id_eq, apply: lambda { |records, values, _options|
    records.rateplan_uuid_filter(values[0])
  }

  filter :account_id_eq, apply: lambda { |records, values, _options|
    records.rateplan_uuid_filter(values[0])
  }

  def self.apply_allowed_accounts(_records, options)
    context = options[:context]
    scope = _records.where_customer(context[:customer_id])
    scope = scope.where_account(context[:allowed_account_ids]) if context[:allowed_account_ids].present?
    scope
  end
end
