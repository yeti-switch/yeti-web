# frozen_string_literal: true

FactoryBot.define do
  factory :scheduler_range, class: 'System::SchedulerRange' do
    months { [] }
    days { [] }
    weekdays { [] }
    from_time { nil }
    till_time { nil }
  end
end
