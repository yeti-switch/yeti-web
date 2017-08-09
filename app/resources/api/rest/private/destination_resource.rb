class Api::Rest::Private::DestinationResource < JSONAPI::Resource
  attributes :enabled, :rateplan_id, :next_rate, :connect_fee, :initial_interval, :next_interval, :dp_margin_fixed,
             :dp_margin_percent, :rate_policy_id, :initial_rate, :asr_limit, :acd_limit, :short_calls_limit,
             :prefix, :reject_calls, :use_dp_intervals, :valid_from, :valid_till, :profit_control_mode_id, :external_id

  def self.updatable_fields(context)
    [
      :enabled,
      :prefix,
      :rateplan_id,
      :next_rate,
      :connect_fee,
      :initial_interval,
      :next_interval,
      :dp_margin_fixed,
      :dp_margin_percent,
      :rate_policy_id,
      :initial_rate,
      :reject_calls,
      :use_dp_intervals,
      :valid_from,
      :valid_till,
      :profit_control_mode_id,
      :external_id,
      :asr_limit,
      :acd_limit,
      :short_calls_limit
    ]
  end

  def self.creatable_fields(context)
    self.updatable_fields(context)
  end
end
