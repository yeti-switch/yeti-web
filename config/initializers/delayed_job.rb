# frozen_string_literal: true

require 'delayed_job/fill_provider_job_id'
require 'delayed_job/unique_name'

Delayed::Worker.destroy_failed_jobs = false
