# frozen_string_literal: true

# == Schema Information
#
# Table name: stats.active_calls
#
#  id         :bigint(8)        not null, primary key
#  count      :integer(4)       not null
#  created_at :timestamptz
#  node_id    :integer(4)       not null
#

FactoryBot.define do
  factory :stats_active_call, class: Stats::ActiveCall do
    count { rand(100) }
    node { Node.take! || FactoryBot.create(:node) }
  end
end
