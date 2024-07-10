# frozen_string_literal: true

# == Schema Information
#
# Table name: events
#
#  id         :integer(4)       not null, primary key
#  command    :string           not null
#  last_error :string
#  retries    :integer(4)       default(0), not null
#  created_at :timestamptz      not null
#  updated_at :timestamptz
#  node_id    :integer(4)       not null
#
# Foreign Keys
#
#  events_node_id_fkey  (node_id => nodes.id)
#

FactoryBot.define do
  factory :event, class: Event do
    command { 'reload_registrations' }
    retries { 5 }
    node
    created_at { Time.now.utc }

    trait :uniq_command do
      sequence(:command) { |n| "reload_registrations_#{n}" }
    end
  end
end
