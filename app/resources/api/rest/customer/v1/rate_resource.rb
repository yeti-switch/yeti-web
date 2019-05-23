# frozen_string_literal: true

class Api::Rest::Customer::V1::RateResource < BaseResource
  model_name 'Routing::Destination'

  key_type :uuid
  primary_key :uuid
  paginator :paged

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

  ransack_filter :enabled, type: :boolean
  ransack_filter :prefix, type: :string
  ransack_filter :next_rate, type: :number
  ransack_filter :connect_fee, type: :number
  ransack_filter :initial_interval, type: :number
  ransack_filter :next_interval, type: :number
  ransack_filter :dp_margin_fixed, type: :number
  ransack_filter :dp_margin_percent, type: :number
  ransack_filter :initial_rate, type: :number
  ransack_filter :reject_calls, type: :boolean
  ransack_filter :use_dp_intervals, type: :boolean
  ransack_filter :valid_from, type: :datetime
  ransack_filter :valid_till, type: :datetime
  ransack_filter :external_id, type: :number
  ransack_filter :asr_limit, type: :number
  ransack_filter :acd_limit, type: :number
  ransack_filter :short_calls_limit, type: :number
  ransack_filter :quality_alarm, type: :boolean
  ransack_filter :uuid, type: :uuid
  ransack_filter :dst_number_min_length, type: :number
  ransack_filter :dst_number_max_length, type: :number
  ransack_filter :reverse_billing, type: :boolean

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
