# frozen_string_literal: true

module CustomRspecHelper
  def safe_subject
    subject
  rescue StandardError
    nil
  end

  # @see ActiveJob::TestHelper
  def with_real_active_job_adapter
    queue_adapter_changed_jobs.each(&:disable_test_adapter)
    begin
      yield
    ensure
      queue_adapter_changed_jobs.each { |klass| klass.enable_test_adapter(queue_adapter_for_test) }
    end
  end
end
