# frozen_string_literal: true

# == Schema Information
#
# Table name: stats.termination_quality_stats
#
#  id                  :integer          not null, primary key
#  dialpeer_id         :integer
#  gateway_id          :integer
#  time_start          :datetime         not null
#  success             :boolean          not null
#  duration            :integer          not null
#  pdd                 :float
#  early_media_present :boolean
#  destination_id      :integer
#

FactoryBot.define do
  factory :quality_stat, class: Stats::TerminationQualityStat do
    time_start { Time.now.utc }
    success { true }
    duration { 2 }

    trait :filled do
      dialpeer
      gateway
    end
  end
end
