# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.jobs
#
#  id             :bigint(8)        not null, primary key
#  last_duration  :decimal(, )
#  last_exception :string
#  last_run_at    :datetime
#  name           :string           not null
#
FactoryBot.define do
  factory :cron_job_info, class: CronJobInfo do
    name { nil } # required

    trait :active do
      last_run_at { 1.minute.ago.utc }
      last_duration { rand(100) + rand.round(6) }
    end

    trait :failed do
      active
      last_exception { "StandardError test error\n#{caller.join("\n")}" }
    end
  end
end
