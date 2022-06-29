# frozen_string_literal: true

# == Schema Information
#
# Table name: stats.active_call_orig_gateways
#
#  id         :bigint(8)        not null, primary key
#  count      :integer(4)       not null
#  created_at :datetime
#  gateway_id :integer(4)       not null
#

FactoryBot.define do
  factory :stats_active_call_orig_gw, class: Stats::ActiveCallOrigGateway do
    count { rand(100) }
    gateway { Gateway.take! || FactoryBot.create(:gateway) }
  end
end
