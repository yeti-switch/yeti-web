# frozen_string_literal: true

module CdrProcessor
  class ConsumerGroup < CdrProcessor::Consumer
    # {'type' => [events]}
    def perform_group(_events_hash)
      raise 'realize me'
    end

    def perform_events(events)
      events = sum_events(events)
      perform_group_with_timing(events) if events.present?
    end

    def sum_events(events)
      events.each_with_object({}) do |event, result|
        result[event.type] ||= []
        result[event.type] << event
      end
    end

    private

    def perform_group_with_timing(events)
      start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      perform_group(events)
    ensure
      @last_perform_group_duration_ms = (Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time) * 1000
    end
  end
end
