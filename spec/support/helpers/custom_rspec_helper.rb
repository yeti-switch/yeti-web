# frozen_string_literal: true

module CustomRspecHelper
  def safe_subject
    subject
  rescue StandardError
    nil
  end

  def with_dj_queue_adapter(*job_klasses, &)
    with_queue_adapter(:delayed_job, *job_klasses, &)
  end

  def with_queue_adapter(adapter_name, *job_klasses)
    raise ArgumentError if job_klasses.empty?

    begin
      job_klasses.each { |klass| klass.queue_adapter = adapter_name }
      yield
    ensure
      # we need to set the exact same adapter for all job classes, because it will affect matchers
      test_adapter = ActiveJob::Base.queue_adapter
      job_klasses.each { |klass| klass.queue_adapter = test_adapter }
    end
  end
end
