# frozen_string_literal: true

module TravelMonotonicHelpers
  # inspired by ActiveSupport::Testing::TimeHelpers
  # allows to stub ::Process.clock_gettime(::Process::CLOCK_MONOTONIC)

  def monotonic_stubs
    @monotonic_stubs ||= ActiveSupport::Testing::SimpleStubs.new
  end

  # @param interval [Numeric] seconds interval (positive - future, negative - past).
  def travel_monotonic_interval(interval, &block)
    seconds = ::Process.clock_gettime(::Process::CLOCK_MONOTONIC) + interval
    travel_monotonic(seconds, &block)
  end

  def travel_monotonic(seconds = nil, &block)
    raise ArgumentError, 'block required' if block.nil?

    if monotonic_stubs.stubbing(::Process, :clock_gettime)
      raise ArgumentError, 'already within travel_monotonic'
    end

    seconds ||= ::Process.clock_gettime(::Process::CLOCK_MONOTONIC)
    monotonic_stubs.stub_object(::Process, :clock_gettime) { |*_args| seconds }
    begin
      yield
    ensure
      monotonic_stubs.unstub_all!
    end
  end
end
