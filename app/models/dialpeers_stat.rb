# frozen_string_literal: true

# == Schema Information
#
# Table name: dialpeers_stats
#
#  id             :bigint(8)        not null, primary key
#  acd            :float
#  asr            :float
#  calls          :bigint(8)        not null
#  calls_fail     :bigint(8)        not null
#  calls_success  :bigint(8)        not null
#  locked_at      :timestamptz
#  total_duration :bigint(8)        not null
#  unlocked_at    :timestamptz
#  created_at     :timestamptz      not null
#  updated_at     :timestamptz      not null
#  dialpeer_id    :bigint(8)        not null
#
# Indexes
#
#  unique_dp  (dialpeer_id) UNIQUE
#

class DialpeersStat < ApplicationRecord
  belongs_to :dialpeer
end
