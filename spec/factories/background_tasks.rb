# frozen_string_literal: true

# == Schema Information
#
# Table name: delayed_jobs
#
#  id          :integer(4)       not null, primary key
#  attempts    :integer(4)       default(0), not null
#  failed_at   :timestamptz
#  handler     :text             not null
#  last_error  :text
#  locked_at   :timestamptz
#  locked_by   :string(255)
#  priority    :integer(4)       default(0), not null
#  queue       :string(255)
#  run_at      :timestamptz
#  unique_name :string
#  created_at  :timestamptz      not null
#  updated_at  :timestamptz      not null
#
# Indexes
#
#  delayed_jobs_priority  (priority,run_at)
#

FactoryBot.define do
  factory :background_task, class: 'BackgroundTask' do
    priority { 0 }
    attempts { 0 }
    handler { "--- !ruby/object:ActiveJob::QueueAdapters::DelayedJobAdapter::JobWrapper\njob_data:\n  job_class: Worker::CdrExportJob\n  job_id: 71b02934-f68e-4a98-a90c-de8d274a37ed\n  provider_job_id: \n  queue_name: cdr_export\n  priority: \n  arguments:\n  - 1\n  executions: 0\n  locale: en\n" }
  end
end
