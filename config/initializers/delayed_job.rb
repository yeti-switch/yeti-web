# frozen_string_literal: true

require 'delayed_job/fill_provider_job_id'
require 'delayed_job/job_name'
require 'delayed_job/unique_name'
require 'prometheus_config'

if PrometheusConfig.enabled?
  require 'delayed_job/prometheus_plugin'
end

if ENV['DELAYED_JOB_NO_DAEMON'].present?
  require 'delayed_job/no_daemon'
end

if ENV['SKIP_RAILS_SEMANTIC_LOGGER'] != 'true'
  require 'delayed_job/log_job_tags'
  require 'delayed_job/semantic_logger_reopen'
end

Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.read_ahead = 1
Delayed::Worker.raise_signal_exceptions = true
