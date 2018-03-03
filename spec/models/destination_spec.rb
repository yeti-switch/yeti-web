# == Schema Information
#
# Table name: class4.destinations
#
#  id                     :integer          not null, primary key
#  enabled                :boolean          not null
#  prefix                 :string           not null
#  rateplan_id            :integer          not null
#  next_rate              :decimal(, )      not null
#  connect_fee            :decimal(, )      default(0.0)
#  initial_interval       :integer          default(1), not null
#  next_interval          :integer          default(1), not null
#  dp_margin_fixed        :decimal(, )      default(0.0), not null
#  dp_margin_percent      :decimal(, )      default(0.0), not null
#  rate_policy_id         :integer          default(1), not null
#  initial_rate           :decimal(, )      not null
#  reject_calls           :boolean          default(FALSE), not null
#  use_dp_intervals       :boolean          default(FALSE), not null
#  valid_from             :datetime         not null
#  valid_till             :datetime         not null
#  profit_control_mode_id :integer
#  network_prefix_id      :integer
#  external_id            :integer
#  asr_limit              :float            default(0.0), not null
#  acd_limit              :float            default(0.0), not null
#  short_calls_limit      :float            default(0.0), not null
#  quality_alarm          :boolean          default(FALSE), not null
#  routing_tag_id         :integer
#  uuid                   :uuid             not null
#  dst_number_min_length  :integer          default(0), not null
#  dst_number_max_length  :integer          default(100), not null
#  reverse_billing        :boolean          default(FALSE), not null
#  routing_tag_ids        :integer          default([]), not null, is an Array
#

require 'spec_helper'

describe Destination, type: :model do

  context 'validate routing_tag_ids' do
    include_examples :test_model_with_routing_tag_ids
  end

end
