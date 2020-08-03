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
#  locked_at      :datetime
#  total_duration :bigint(8)        not null
#  unlocked_at    :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  dialpeer_id    :bigint(8)        not null
#
# Indexes
#
#  unique_dp  (dialpeer_id) UNIQUE
#

class DialpeersStat < ActiveRecord::Base
  belongs_to :dialpeer
end
