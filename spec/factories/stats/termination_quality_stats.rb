# frozen_string_literal: true

# == Schema Information
#
# Table name: stats.termination_quality_stats
#
#  id                  :bigint(8)        not null, primary key
#  duration            :bigint(8)        not null
#  early_media_present :boolean
#  pdd                 :float
#  success             :boolean          not null
#  time_start          :timestamptz      not null
#  destination_id      :bigint(8)
#  dialpeer_id         :bigint(8)
#  gateway_id          :integer(4)
#
# Indexes
#
#  termination_quality_stats_dialpeer_id_idx  (dialpeer_id)
#  termination_quality_stats_gateway_id_idx   (gateway_id)
#

FactoryBot.define do
  factory :quality_stat, class: 'Stats::TerminationQualityStat' do
    time_start { Time.now.utc }
    success { true }
    duration { 2 }

    trait :filled do
      dialpeer
      gateway
    end
  end
end
