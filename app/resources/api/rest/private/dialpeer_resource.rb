class Api::Rest::Private::DialpeerResource < JSONAPI::Resource
  attributes :enabled, :routing_group_id, :next_rate, :connect_fee, :vendor_id, :account_id, :initial_rate,
             :initial_interval, :next_interval, :valid_from, :valid_till,
             :prefix, :src_rewrite_rule, :dst_rewrite_rule, :acd_limit, :asr_limit, :gateway_id, :src_rewrite_result,
             :dst_rewrite_result, :locked, :priority, :exclusive_route, :capacity, :lcr_rate_multiplier,
             :gateway_group_id, :force_hit_rate, :network_prefix_id, :created_at, :short_calls_limit, :external_id

  def self.updatable_fields(context)
    [
      :enabled,
      :prefix,
      :src_rewrite_rule,
      :dst_rewrite_rule,
      :acd_limit,
      :asr_limit,
      :gateway_id,
      :routing_group_id,
      :next_rate,
      :connect_fee,
      :vendor_id,
      :account_id,
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
      :gateway_group_id,
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
