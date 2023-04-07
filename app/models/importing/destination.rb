# frozen_string_literal: true

# == Schema Information
#
# Table name: data_import.import_destinations
#
#  id                       :bigint(8)        not null, primary key
#  acd_limit                :float
#  asr_limit                :float
#  connect_fee              :decimal(, )
#  dp_margin_fixed          :decimal(, )
#  dp_margin_percent        :decimal(, )
#  dst_number_max_length    :integer(4)
#  dst_number_min_length    :integer(4)
#  enabled                  :boolean
#  error_string             :string
#  initial_interval         :integer(4)
#  initial_rate             :decimal(, )
#  is_changed               :boolean
#  next_interval            :integer(4)
#  next_rate                :decimal(, )
#  prefix                   :string
#  profit_control_mode_name :string
#  rate_group_name          :string
#  rate_policy_name         :string
#  reject_calls             :boolean
#  reverse_billing          :boolean
#  routing_tag_ids          :integer(2)       default([]), not null, is an Array
#  routing_tag_mode_name    :string
#  routing_tag_names        :string
#  short_calls_limit        :float
#  use_dp_intervals         :boolean
#  valid_from               :timestamptz
#  valid_till               :timestamptz
#  network_prefix_id        :integer(4)
#  o_id                     :bigint(8)
#  profit_control_mode_id   :integer(2)
#  rate_group_id            :integer(4)
#  rate_policy_id           :integer(4)
#  routing_tag_mode_id      :integer(2)
#

class Importing::Destination < Importing::Base
  self.table_name = 'data_import.import_destinations'

  belongs_to :rate_group, class_name: 'Routing::RateGroup', optional: true
  belongs_to :routing_tag_mode, class_name: 'Routing::RoutingTagMode', foreign_key: :routing_tag_mode_id, optional: true

  self.import_attributes = %w[enabled prefix reject_calls rate_group_id
                              initial_interval next_interval initial_rate next_rate
                              connect_fee rate_policy_id reverse_billing dp_margin_fixed dp_margin_percent use_dp_intervals
                              valid_from valid_till profit_control_mode_id
                              asr_limit acd_limit short_calls_limit
                              dst_number_min_length dst_number_max_length
                              routing_tag_ids routing_tag_mode_id]

  import_for ::Routing::Destination

  def rate_policy_display_name
    rate_policy_id.nil? ? 'unknown' : Routing::DestinationRatePolicy::POLICIES[rate_policy_id]
  end

  def profit_control_mode_display_name
    profit_control_mode_id.nil? ? 'nil' : Routing::RateProfitControlMode::MODES[rate_policy_id]
  end

  def self.after_import_hook
    resolve_array_of_tags('routing_tag_ids', 'routing_tag_names')
    resolve_null_tag('routing_tag_ids', 'routing_tag_names')
    resolve_integer_constant('rate_policy_id', 'rate_policy_name', Routing::DestinationRatePolicy::POLICIES)
    resolve_integer_constant('profit_control_mode_id', 'profit_control_mode_name', Routing::RateProfitControlMode::MODES)
    super
  end
end
