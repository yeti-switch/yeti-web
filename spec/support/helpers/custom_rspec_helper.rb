# frozen_string_literal: true

module CustomRspecHelper
  def safe_subject
    subject
  rescue StandardError
    nil
  end

  def enqueue_delayed_job(active_job_class, *arguments)
    old_test_adapter = active_job_class._test_adapter
    old_adapter = active_job_class.queue_adapter
    active_job_class._test_adapter = nil
    active_job_class.queue_adapter = :delayed_job
    begin
      active_job_class.perform_later(*arguments)
      Delayed::Job.last!
    ensure
      active_job_class._test_adapter = old_test_adapter
      active_job_class.queue_adapter = old_adapter
    end
  end
end
