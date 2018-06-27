# == Schema Information
#
# Table name: data_import.import_destinations
#
#  id                       :integer          not null, primary key
#  o_id                     :integer
#  prefix                   :string
#  rateplan_name            :string
#  rateplan_id              :integer
#  connect_fee              :decimal(, )
#  enabled                  :boolean
#  reject_calls             :boolean
#  initial_interval         :integer
#  next_interval            :integer
#  initial_rate             :decimal(, )
#  next_rate                :decimal(, )
#  rate_policy_id           :integer
#  dp_margin_fixed          :decimal(, )
#  dp_margin_percent        :decimal(, )
#  rate_policy_name         :string
#  use_dp_intervals         :boolean
#  error_string             :string
#  valid_from               :datetime
#  valid_till               :datetime
#  profit_control_mode_id   :integer
#  profit_control_mode_name :string
#  network_prefix_id        :integer
#  asr_limit                :float
#  acd_limit                :float
#  short_calls_limit        :float
#  reverse_billing          :boolean
#  routing_tag_ids          :integer          default([]), not null, is an Array
#  routing_tag_names        :string
#  dst_number_min_length    :integer
#  dst_number_max_length    :integer
#  routing_tag_mode_id      :integer
#  routing_tag_mode_name    :string
#

class Importing::Destination < Importing::Base
  self.table_name = 'data_import.import_destinations'

  belongs_to :rateplan, class_name: '::Rateplan'
  belongs_to :rate_policy, class_name: '::DestinationRatePolicy'
  belongs_to :profit_control_mode, class_name: 'Routing::RateProfitControlMode', foreign_key: 'profit_control_mode_id'
  belongs_to :routing_tag_mode, class_name: 'Routing::RoutingTagMode', foreign_key: :routing_tag_mode_id


  self.import_attributes =['enabled', 'prefix', 'reject_calls', 'rateplan_id',
                           'initial_interval', 'next_interval', 'initial_rate', 'next_rate',
                           'connect_fee', 'rate_policy_id', 'reverse_billing', 'dp_margin_fixed', 'dp_margin_percent', 'use_dp_intervals',
                           'valid_from', 'valid_till', 'profit_control_mode_id',
                           'asr_limit', 'acd_limit', 'short_calls_limit',
                           'dst_number_min_length', 'dst_number_max_length',
                           'routing_tag_ids', 'routing_tag_mode_id'
  ]

  self.import_class = ::Routing::Destination

  def self.after_import_hook(unique_columns = [])
    self.resolve_array_of_tags('routing_tag_ids', 'routing_tag_names')
    self.resolve_null_tag('routing_tag_ids', 'routing_tag_names')
    super
  end

end
