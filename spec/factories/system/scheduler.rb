# frozen_string_literal: true

FactoryBot.define do
  factory :scheduler, class: 'System::Scheduler' do
    sequence(:name) { |n| "scheduler_#{n}" }
    enabled { true }
    use_reject_calls { true }
    timezone { Yeti::TimeZoneHelper.all.sample }
  end
end
