class Api::Rest::Admin::DestinationResource < JSONAPI::Resource
  model_name 'Routing::Destination'
  attributes :enabled, :next_rate, :connect_fee, :initial_interval, :next_interval, :dp_margin_fixed,
             :dp_margin_percent, :initial_rate, :asr_limit, :acd_limit, :short_calls_limit,
             :prefix, :reject_calls, :use_dp_intervals, :valid_from, :valid_till, :external_id,
             :routing_tag_ids, :dst_number_min_length, :dst_number_max_length

  has_one :rateplan
  has_one :rate_policy, class_name: 'DestinationRatePolicy'
  has_one :profit_control_mode, class_name: 'Routing::RateProfitControlMode'
  has_one :routing_tag_mode, class_name: 'Routing::RoutingTagMode'

  filters :external_id, :prefix, :rateplan_id

  def self.updatable_fields(_context)
    %i[
      enabled
      prefix
      rateplan
      next_rate
      connect_fee
      initial_interval
      next_interval
      dp_margin_fixed
      dp_margin_percent
      rate_policy
      initial_rate
      reject_calls
      use_dp_intervals
      valid_from
      valid_till
      profit_control_mode
      routing_tag_mode
      external_id
      asr_limit
      acd_limit
      short_calls_limit
      routing_tag_ids
      dst_number_min_length
      dst_number_max_length
    ]
  end

  def self.creatable_fields(context)
    self.updatable_fields(context)
  end
end
