# frozen_string_literal: true

class Pgq::Event
  attr_reader :type, :data, :id, :consumer, :time

  def initialize(consumer, event)
    @id = event['ev_id']
    @type = event['ev_type']
    @time = event['ev_time']
    @consumer = consumer
    @data = @consumer.coder.load(event['ev_data']) if event['ev_data']
  end

  def done?
    @consumer.event_done?(@id)
  end

  def done!
    @consumer.event_done!(@id)
  end

  def retry!(seconds = 0)
    @consumer.event_retry(@id, seconds)
  end

  def self.exception_message(e)
    <<~EXCEPTION
      Exception happend
      Error occurs: #{e.class.inspect}(#{e.message})
      Backtrace: #{begin
                     e.backtrace.join("\n")
                   rescue StandardError
                     ''
                   end}
    EXCEPTION
  end

  # Prepare string with exception details
  def exception_message(e)
    <<~EXCEPTION
      Exception happend
      Type: #{@type.inspect}
      Data: #{@data.inspect}
      Error occurs: #{e.class.inspect}(#{e.message})
      Backtrace: #{begin
                     e.backtrace.join("\n")
                   rescue StandardError
                     ''
                   end}
    EXCEPTION
  end
end
