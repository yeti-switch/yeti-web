# frozen_string_literal: true

class Api::Rest::Admin::Routing::DestinationResource < ::BaseResource
  model_name 'Routing::Destination'

  module CONST
    SYSTEM_NAMESPACE_RELATIONS = %w[Country].freeze
  end.freeze

  attributes :enabled, :next_rate, :connect_fee, :initial_interval, :next_interval, :dp_margin_fixed,
             :dp_margin_percent, :initial_rate, :asr_limit, :acd_limit, :short_calls_limit,
             :prefix, :reject_calls, :use_dp_intervals, :valid_from, :valid_till, :external_id,
             :routing_tag_ids, :dst_number_min_length, :dst_number_max_length, :reverse_billing,
             :profit_control_mode_id, :rate_policy_id

  paginator :paged

  has_one :rate_group, class_name: 'RateGroup'
  has_one :routing_tag_mode, class_name: 'RoutingTagMode'
  has_one :country, class_name: 'Country', force_routed: true, foreign_key_on: :related

  filters :external_id, :prefix, :rate_group_id

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
  ransack_filter :profit_control_mode_id, type: :number
  ransack_filter :rate_policy_id, type: :number
  ransack_filter :rateplan_id, type: :foreign_key, column: :rate_group_rateplans_id
  ransack_filter :country_id, type: :foreign_key, column: :network_prefix_country_id

  def self.updatable_fields(_context)
    %i[
      enabled
      prefix
      rate_group
      next_rate
      connect_fee
      initial_interval
      next_interval
      dp_margin_fixed
      dp_margin_percent
      rate_policy_id
      initial_rate
      reverse_billing
      reject_calls
      use_dp_intervals
      valid_from
      valid_till
      profit_control_mode_id
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
    updatable_fields(context)
  end

  def self.resource_for(type)
    if type.in?(CONST::SYSTEM_NAMESPACE_RELATIONS)
      "Api::Rest::Admin::System::#{type}Resource".safe_constantize
    else
      super
    end
  end
end
