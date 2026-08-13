# frozen_string_literal: true

require 'bunny'

module CdrProcessor
  module Processors
    class CdrAmqp < CdrProcessor::ConsumerGroup
      def initialize(logger, queue, consumer, options)
        super
        conn = CdrProcessor::AmqpFactory.instance.get_connection(options['connect'])
        conn.start
        set_exchange_and_queue conn
      end

      # Unlike the other processors this one keeps the CdrProcessor::Event
      # objects: every CDR is published on its own, so it is acknowledged by its
      # own pgq event id right after it was published.
      def perform_events(events)
        perform_group_with_timing(events)
      end

      # [CdrProcessor::Event]
      def perform_group(events)
        send_events_by_amqp events
      end

      def send_event_by_amqp(event)
        logger.debug { "Sending cdr #{event.data['id']}, event #{event.id}" }
        return if event_done?(event.id)

        @exchange.publish(event.data.to_json)
        event_done!(event.id)
      end

      def send_events_by_amqp(events)
        events.each { |event| send_event_by_amqp event }
      end

      private

      def set_exchange_and_queue(conn)
        ch = conn.create_channel
        @queue = ch.queue 'cdr_streaming', durable: true
        @exchange = ch.fanout 'cdr_amqp', durable: true
        @queue.bind @exchange
      end
    end
  end
end
