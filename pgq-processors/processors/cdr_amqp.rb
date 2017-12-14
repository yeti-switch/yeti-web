require 'bunny'
require 'byebug'

class CdrAmqp < Pgq::ConsumerGroup
  @consumer_name = 'cdr_amqp'

  def initialize(logger, queue, consumer, options)
    super
    @consumer = consumer
    @options = options
    conn = AmqpFactory.instance.get_connection(options[:connect])
    conn.start
    set_exchange_and_queue conn
  end

  def perform_events(events)
    perform_group(events.map &:data)
  end

  def perform_group(group)
    send_events_by_amqp group
  end

  def send_event_by_amqp(event)
    logger.info "Sending cdr #{event.try :id}"
    unless event_done?(event[:id])
      @exchange.publish(event.to_json)
      event_done!(event[:id])
    end
  end

  def send_events_by_amqp(group)
    group.map { |event| send_event_by_amqp event }
  end

  private
  def set_exchange_and_queue(conn)
    ch = conn.create_channel
    @queue  = ch.queue 'cdr_streaming', durable: true
    @exchange  = ch.fanout 'cdr_amqp', durable: true
    @queue.bind @exchange
  end
end
