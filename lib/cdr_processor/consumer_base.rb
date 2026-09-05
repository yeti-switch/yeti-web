# frozen_string_literal: true

module CdrProcessor
  class ConsumerBase
    attr_accessor :logger, :queue_name, :consumer_name
    attr_reader :last_perform_group_duration_ms

    def self.cdr_connection
      CdrProcessor::CdrDb.connection
    end

    def cdr_connection
      self.class.cdr_connection
    end

    def self.primary_connection
      CdrProcessor::PrimaryDb.connection
    end

    def primary_connection
      self.class.primary_connection
    end

    # == coder

    def self.coder
      CdrProcessor::JsonCoder
    end

    def coder
      self.class.coder
    end

    # == consumer part

    def initialize(logger = nil, custom_queue_name = nil, custom_consumer_name = nil)
      self.queue_name = custom_queue_name
      self.consumer_name = custom_consumer_name
      raise ArgumentError, "queue_name is required, define 'queue' in config" if queue_name.blank?
      raise ArgumentError, "consumer_name is required, define 'consumer' in config" if consumer_name.blank?

      self.logger = logger
      @batch_id = nil
      @consumer_lock_taken = false
    end

    def perform_batch
      events = []
      safe_batch_perform do
        return 0 unless consumer_lock_ok?

        pgq_events = get_batch_events

        return 0 if pgq_events.nil? # if no batch

        if pgq_events.blank? # if batch is empty
          log_info 'Empty batch'
          finish_batch
          return -1
        end

        events = pgq_events.map { |ev| CdrProcessor::Event.new(self, ev) }
        size = events.size
        log_info "batch(#{@batch_id}): events #{size}"

        perform_events(events)

        finish_batch
      end

      events.size
    end

    # pgq.next_batch reads pgq.subscription without FOR UPDATE, so two workers
    # sharing a consumer can be handed different batch ids for the same events.
    # Losing the lock after it was taken means our session died, which breaks
    # that exclusivity - fail so the worker restarts on a fresh connection.
    def consumer_lock_ok?
      if @consumer_lock_taken
        raise "Lost the advisory lock on #{queue_name}/#{consumer_name}" unless CdrProcessor::CdrDb.pgq_consumer_lock?(queue_name, consumer_name)

        return true
      end

      @consumer_lock_taken = CdrProcessor::CdrDb.pgq_consumer_lock!(queue_name, consumer_name)
      # the loop retries every sleep_time, so report the wait only once
      unless @consumer_lock_taken || @consumer_lock_reported
        @consumer_lock_reported = true
        log_info "Another instance holds #{queue_name}/#{consumer_name}, idling"
      end
      @consumer_lock_taken
    end

    def safe_batch_perform
      yield
    rescue SystemExit
      log_error('System Exit')
    rescue StandardError => e
      log_error("<#{e.class}> #{e.message}\n#{e.backtrace&.join("\n")}")
      CdrProcessor::Worker.shutdown!(e) unless CdrProcessor::Worker.interrupted?
    end

    def perform_events(events)
      events.each do |event|
        perform_event(event)
      end
    end

    def perform_event(event)
      logger.debug "performing event: Event: #{event.id}, Batch: #{@batch_id}"

      CdrProcessor::Worker.check_interrupted(__FILE__, __LINE__)

      type = event.type
      data = event.data

      if event.done?
        log_debug("An event #{type} has done")
        return
      end

      perform(type, data)

      event.done!
      log_debug("Set an event #{type} to done")
    rescue Exception => ex
      log_error(event.exception_message(ex))
      raise ex
    end

    def perform(_type, *_data)
      raise 'realize me'
    end

    def get_batch_events
      @batch_id = CdrProcessor::CdrDb.pgq_next_batch(queue_name, consumer_name)
      return nil unless @batch_id

      CdrProcessor::CdrDb.pgq_get_batch_events(consumer_name, @batch_id)
    end

    def finish_batch
      return unless @batch_id

      log_debug "Finishing batch #{@batch_id}"

      CdrProcessor::CdrDb.pgq_finish_batch(@batch_id)
      @batch_id = nil
    end

    def event_retry(event_id, seconds = 0)
      CdrProcessor::CdrDb.pgq_event_retry(@batch_id, event_id, seconds)
    end

    def event_done?(event_id)
      CdrProcessor::CdrDb.pgq_event_done?(@consumer_name, @batch_id, event_id)
    end

    def event_done!(event_id)
      CdrProcessor::CdrDb.pgq_event_done!(@consumer_name, @batch_id, event_id)
    end

    # == log methods

    def log_debug(mes)
      @logger&.debug(mes)
    end

    def log_info(mes)
      @logger&.info(mes)
    end

    def log_error(mes)
      @logger&.error(mes)
    end
  end
end
