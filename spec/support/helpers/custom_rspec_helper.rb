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

  # Allows to move Process.clock_gettime within block
  # @param interval [Float,Integer] will change Process.clock_gettime by interval
  # @yield within interval shift.
  #   ::Process.clock_gettime(::Process::CLOCK_MONOTONIC)
  #   will freeze on current + interval inside block
  # @example Usage:
  #
  #   ::Process.clock_gettime(::Process::CLOCK_MONOTONIC) # will be for example 1900
  #   travel_process_clock(-100) do
  #    ::Process.clock_gettime(::Process::CLOCK_MONOTONIC) # will be freezed on 1800
  #   end
  #   ::Process.clock_gettime(::Process::CLOCK_MONOTONIC) # will be greater than 1900 and unfreezed
  #
  def travel_process_clock(interval)
    raise ArgumentError, 'block must be passed' unless block_given?

    now = ::Process.clock_gettime(::Process::CLOCK_MONOTONIC)
    stubs = ActiveSupport::Testing::SimpleStubs.new
    stubs.stub_object(Process, :clock_gettime) { |*_args| now + interval }
    begin
      yield
    ensure
      stubs.unstub_all!
    end
  end
end
