# frozen_string_literal: true

# == Schema Information
#
# Table name: delayed_jobs
#
#  id         :integer          not null, primary key
#  priority   :integer          default(0), not null
#  attempts   :integer          default(0), not null
#  handler    :text             not null
#  last_error :text
#  run_at     :datetime
#  locked_at  :datetime
#  failed_at  :datetime
#  locked_by  :string(255)
#  queue      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :background_task, class: BackgroundTask do
    priority { 0 }
    attempts { 0 }
    handler { "--- !ruby/object:ActiveJob::QueueAdapters::DelayedJobAdapter::JobWrapper\njob_data:\n  job_class: Worker::CdrExportJob\n  job_id: 71b02934-f68e-4a98-a90c-de8d274a37ed\n  provider_job_id: \n  queue_name: cdr_export\n  priority: \n  arguments:\n  - 1\n  executions: 0\n  locale: en\n" }
  end
end
