# frozen_string_literal: true

# == Schema Information
#
# Table name: gateways_stats
#
#  id             :integer(4)       not null, primary key
#  acd            :float
#  asr            :float
#  calls          :bigint(8)        not null
#  calls_fail     :bigint(8)        not null
#  calls_success  :bigint(8)        not null
#  locked_at      :datetime
#  total_duration :bigint(8)        not null
#  unlocked_at    :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  gateway_id     :integer(4)       not null
#
# Indexes
#
#  unique_gw  (gateway_id) UNIQUE
#

class GatewaysStat < ActiveRecord::Base
  belongs_to :gateway
end
