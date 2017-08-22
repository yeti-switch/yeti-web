class Api::Rest::Private::DestinationResource < JSONAPI::Resource
  attributes :enabled, :next_rate, :connect_fee, :initial_interval, :next_interval, :dp_margin_fixed,
             :dp_margin_percent, :initial_rate, :asr_limit, :acd_limit, :short_calls_limit,
             :prefix, :reject_calls, :use_dp_intervals, :valid_from, :valid_till, :external_id

  has_one :rateplan
  has_one :rate_policy, class_name: 'DestinationRatePolicy'
  has_one :profit_control_mode, class_name: 'Routing::RateProfitControlMode'


  def self.updatable_fields(context)
    [
      :enabled,
      :prefix,
      :rateplan,
      :next_rate,
      :connect_fee,
      :initial_interval,
      :next_interval,
      :dp_margin_fixed,
      :dp_margin_percent,
      :rate_policy,
      :initial_rate,
      :reject_calls,
      :use_dp_intervals,
      :valid_from,
      :valid_till,
      :profit_control_mode,
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
