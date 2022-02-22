# frozen_string_literal: true

require 'delayed_job/fill_provider_job_id'
require 'delayed_job/unique_name'

if Rails.env.development?
  require 'delayed_job/dev_no_daemon'
end

Delayed::Worker.destroy_failed_jobs = false
