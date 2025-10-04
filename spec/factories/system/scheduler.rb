# frozen_string_literal: true

FactoryBot.define do
  factory :scheduler, class: 'System::Scheduler' do
    sequence(:name) { |n| "scheduler_#{n}" }
    enabled { false }
  end
end
