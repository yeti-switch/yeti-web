class Api::Rest::Admin::DialpeerResource < JSONAPI::Resource
  attributes :enabled, :next_rate, :connect_fee, :initial_rate,
             :initial_interval, :next_interval, :valid_from, :valid_till,
             :prefix, :src_rewrite_rule, :dst_rewrite_rule, :acd_limit, :asr_limit, :src_rewrite_result,
             :dst_rewrite_result, :locked, :priority, :exclusive_route, :capacity, :lcr_rate_multiplier,
             :force_hit_rate, :network_prefix_id, :created_at, :short_calls_limit, :external_id

  has_one :gateway
  has_one :gateway_group
  has_one :routing_group
  has_one :vendor, class_name: 'Contractor'
  has_one :account
  has_many :dialpeer_next_rates

  filters :external_id, :prefix, :routing_group_id

  def self.updatable_fields(context)
    [
      :enabled,
      :prefix,
      :src_rewrite_rule,
      :dst_rewrite_rule,
      :acd_limit,
      :asr_limit,
      :gateway,
      :routing_group,
      :next_rate,
      :connect_fee,
      :vendor,
      :account,
      :src_rewrite_result,
      :dst_rewrite_result,
      :locked,
      :priority,
      :exclusive_route,
      :capacity,
      :lcr_rate_multiplier,
      :initial_rate,
      :initial_interval,
      :next_interval,
      :valid_from,
      :valid_till,
      :gateway_group,
      :force_hit_rate,
      :network_prefix_id,
      :created_at,
      :short_calls_limit,
      :external_id
    ]
  end

  def self.creatable_fields(context)
    self.updatable_fields(context)
  end
end
