# frozen_string_literal: true

require 'active_job'

# ActiveJob tags the records logged by a job with the class of the job and its id, as
# positional tags: `tags: ["Worker::FillInvoiceJob", "07255285-..."]`. Both values are
# already emitted as the `job` and `job_id` fields(Delayed::LogJobTagsPlugin), and an
# array is what a log storage can index the least, so they are tagged by name instead.
#
# Jobs performed outside of delayed_job - `perform_now` in a console, in the specs - are
# covered by this and not by the plugin.
#
# rails_semantic_logger patches the same method, to drop the "ActiveJob" tag that
# ActiveJob::Logging adds by default.
module ActiveJob::NamedLogTags
  private

  # @param tags [Array] the class of the job and its id, empty when enqueuing.
  def tag_logger(*tags, &block)
    return yield if tags.empty? || !logger.respond_to?(:tagged)

    job_class, job_id = tags
    logger.tagged({ job: job_class, job_id: }.compact, &block)
  end
end

ActiveSupport.on_load(:active_job) do
  ActiveJob::Base.prepend ActiveJob::NamedLogTags

  # Without this the frame of #tag_logger, that lives under Rails.root and is a clean
  # frame for the backtrace cleaner, is reported as the source of every job log record
  # by config.active_job.verbose_enqueue_logs(development).
  Rails.backtrace_cleaner.add_silencer { |line| line.include?('lib/active_job/named_log_tags.rb') }
end
