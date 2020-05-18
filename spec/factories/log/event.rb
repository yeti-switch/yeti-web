# frozen_string_literal: true

# == Schema Information
#
# Table name: events
#
#  id         :integer          not null, primary key
#  command    :string           not null
#  retries    :integer          default(0), not null
#  node_id    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime
#  last_error :string
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
