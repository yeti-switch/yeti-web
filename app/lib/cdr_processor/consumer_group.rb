# frozen_string_literal: true

module CdrProcessor
  class ConsumerGroup < CdrProcessor::Consumer
    # {'type' => [events]}
    def perform_group(_events_hash)
      raise 'realize me'
    end

    def perform_events(events)
      events = sum_events(events)
      perform_group(events) if events.present?
    end

    def sum_events(events)
      events.each_with_object({}) do |event, result|
        result[event.type] ||= []
        result[event.type] << event
      end
    end
  end
end
