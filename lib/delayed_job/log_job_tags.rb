# frozen_string_literal: true

require 'delayed_job'
require 'semantic_logger'
require_relative 'job_name'

# Adds the job to every record logged while it runs - by the worker, by ActiveJob and by
# the job itself - so that the logs of one job can be filtered by it:
#
#   * `job` - the class of the job, the same value the Background Tasks page shows;
#   * `dj_id` - the delayed_jobs row, the `id` of the Background Tasks page. Gone from the
#     database once the job succeeds;
#   * `job_id` - the id ActiveJob assigned when the job was enqueued. Kept by the retries
#     of the same job, so it correlates every attempt. Only ActiveJob jobs have it.
#
# Named tags: YetiLogFormatter merges them into the root of the elasticsearch record,
# next to `component`.
class Delayed::LogJobTagsPlugin < Delayed::Plugin
  # @return [Hash]
  def self.log_tags(job)
    { dj_id: job.id, **payload_tags(job) }
  end

  # @return [Hash] empty when the handler of the job does not deserialize. The worker runs
  #   such a job anyway, to fail it, and must not be killed by the logging.
  def self.payload_tags(job)
    payload_object = job.payload_object
    tags = { job: Delayed::JobName.call(payload_object) }
    tags[:job_id] = payload_object.job_data['job_id'] if payload_object.respond_to?(:job_data)
    tags
  rescue StandardError
    {}
  end

  callbacks do |lifecycle|
    lifecycle.around(:perform) do |worker, job, *args, &block|
      SemanticLogger.named_tagged(log_tags(job)) { block.call(worker, job, *args) }
    end
  end
end

Delayed::Worker.plugins << Delayed::LogJobTagsPlugin
