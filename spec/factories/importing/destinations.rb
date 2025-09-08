# frozen_string_literal: true

# == Schema Information
#
# Table name: data_import.import_destinations
#
#  id                       :bigint(8)        not null, primary key
#  acd_limit                :float(24)
#  asr_limit                :float(24)
#  cdo                      :integer(2)
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
#  short_calls_limit        :float(24)
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
FactoryBot.define do
  factory :importing_destination, class: 'Importing::Destination' do
    transient do
      _tags { create_list(:routing_tag, 2) }
    end

    o_id { nil }
    error_string { nil }

    prefix { nil }
    rate_group_name { nil }
    rate_group_id { nil }
    connect_fee { 0 }
    enabled { true }
    reject_calls { false }
    initial_interval { 60 }
    next_interval { 60 }
    initial_rate { 0 }
    next_rate { 0 }
    rate_policy_name { Routing::DestinationRatePolicy::POLICIES[Routing::DestinationRatePolicy::POLICY_FIXED] }
    rate_policy_id { Routing::DestinationRatePolicy::POLICY_FIXED }
    dp_margin_fixed { 0 }
    dp_margin_percent { 0 }
    use_dp_intervals { false }
    valid_from { DateTime.now }
    valid_till { DateTime.now + 5.years }
    asr_limit { 0.0 }
    acd_limit { 0.0 }
    short_calls_limit { 0.0 }
    reverse_billing { false }

    dst_number_min_length { 1 }
    dst_number_max_length { 7 }

    routing_tag_ids { _tags.map(&:id) }
    routing_tag_names { _tags.map(&:name).join(', ') }
  end
end
