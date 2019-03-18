# frozen_string_literal: true

class Api::Rest::Admin::DialpeerResource < BaseResource
  attributes :enabled, :next_rate, :connect_fee, :initial_rate,
             :initial_interval, :next_interval, :valid_from, :valid_till,
             :prefix, :src_rewrite_rule, :dst_rewrite_rule, :acd_limit, :asr_limit, :src_rewrite_result,
             :dst_rewrite_result, :locked, :priority, :exclusive_route, :capacity, :lcr_rate_multiplier,
             :force_hit_rate, :network_prefix_id, :created_at, :short_calls_limit, :external_id,
             :routing_tag_ids

  has_one :gateway
  has_one :gateway_group
  has_one :routing_group
  has_one :vendor, class_name: 'Contractor'
  has_one :account
  has_one :routing_tag_mode, class_name: 'Routing::RoutingTagMode'
  has_one :routeset_discriminator, class_name: 'Routing::RoutesetDiscriminator'

  has_many :dialpeer_next_rates

  filters :external_id, :prefix, :routing_group_id

  ransack_filter :enabled, type: :boolean
  ransack_filter :next_rate, type: :number
  ransack_filter :connect_fee, type: :number
  ransack_filter :initial_rate, type: :number
  ransack_filter :initial_interval, type: :number
  ransack_filter :next_interval, type: :number
  ransack_filter :valid_from, type: :datetime
  ransack_filter :valid_till, type: :datetime
  ransack_filter :prefix, type: :string
  ransack_filter :src_rewrite_rule, type: :string
  ransack_filter :dst_rewrite_rule, type: :string
  ransack_filter :acd_limit, type: :number
  ransack_filter :asr_limit, type: :number
  ransack_filter :src_rewrite_result, type: :string
  ransack_filter :dst_rewrite_result, type: :string
  ransack_filter :locked, type: :boolean
  ransack_filter :priority, type: :number
  ransack_filter :exclusive_route, type: :boolean
  ransack_filter :capacity, type: :number
  ransack_filter :lcr_rate_multiplier, type: :number
  ransack_filter :force_hit_rate, type: :number
  ransack_filter :short_calls_limit, type: :number
  ransack_filter :external_id, type: :number
  #ransack_filter :routing_tag_ids, type: :number           ARRAY

  def self.updatable_fields(_context)
    %i[
      enabled
      prefix
      src_rewrite_rule
      dst_rewrite_rule
      acd_limit
      asr_limit
      gateway
      routing_group
      routeset_discriminator
      next_rate
      connect_fee
      vendor
      account
      routing_tag_mode
      src_rewrite_result
      dst_rewrite_result
      locked
      priority
      exclusive_route
      capacity
      lcr_rate_multiplier
      initial_rate
      initial_interval
      next_interval
      valid_from
      valid_till
      gateway_group
      force_hit_rate
      network_prefix_id
      created_at
      short_calls_limit
      external_id
      routing_tag_ids
    ]
  end

  def self.creatable_fields(context)
    updatable_fields(context)
  end
end
