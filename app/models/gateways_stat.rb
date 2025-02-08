# frozen_string_literal: true

# == Schema Information
#
# Table name: gateways_stats
#
#  id             :integer(4)       not null, primary key
#  acd            :float(24)
#  asr            :float(24)
#  calls          :bigint(8)        not null
#  calls_fail     :bigint(8)        not null
#  calls_success  :bigint(8)        not null
#  locked_at      :timestamptz
#  total_duration :bigint(8)        not null
#  unlocked_at    :timestamptz
#  created_at     :timestamptz      not null
#  updated_at     :timestamptz      not null
#  gateway_id     :integer(4)       not null
#
# Indexes
#
#  unique_gw  (gateway_id) UNIQUE
#

class GatewaysStat < ApplicationRecord
  belongs_to :gateway
end
