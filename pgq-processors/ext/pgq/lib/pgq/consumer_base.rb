require 'pony'
require 'pgq/api'
require 'active_support/inflector' unless ''.respond_to?(:underscore)

class Pgq::ConsumerBase
  @queue_name = 'default'
  @consumer_name = 'default'

  attr_accessor :logger, :queue_name, :consumer_name

  def self.database
    ActiveRecord::Base # can redefine
  end

  def database
    self.class.database
  end

  def self.connection
    database.connection
  end

  def connection
    self.class.connection
  end

  def self.consumer_name
    @consumer_name
  end

  def self.queue_name
    @queue_name
  end

  # == coder

  def self.coder
    JsonCoder
  end

  def coder
    self.class.coder
  end

  # == consumer part

  def initialize(logger = nil, custom_queue_name = nil, custom_consumer_name = nil)
    self.queue_name = custom_queue_name || self.class.queue_name
    self.consumer_name = custom_consumer_name || self.class.consumer_name
    self.logger = logger
    @batch_id = nil
  end


  def perform_batch
    events = []
    begin
      pgq_events = get_batch_events

      if pgq_events.nil? # if no batch
        return 0
      end

      if pgq_events.blank? # if batch is empty
        log_info 'Empty batch'
        finish_batch
        return -1
      end

      events = pgq_events.map { |ev| Pgq::Event.new(self, ev) }
      size = events.size
      log_info "=> batch(#{@batch_id}): events #{size}"

      perform_events(events)

      finish_batch

    rescue SystemExit
       log_error("System Exit")
    rescue StandardError =>e
       log_error(e.message)
       Pony.mail(body: e.backtrace, subject: e.message)
       Pgq::Worker.shutdown!(e.message) unless Pgq::Worker.interrupted?
    end


    events.size
  end

  def perform_events(events)
    events.each do |event|
      perform_event(event)
    end
  end

  def perform_event(event)
    raise 'realize me'
  end

  def perform(type, *data)
    raise 'realize me'
  end

  def get_batch_events
    @batch_id = database.pgq_next_batch(queue_name, consumer_name)
    return nil unless @batch_id
    database.pgq_get_batch_events(consumer_name, @batch_id)
  end

  def finish_batch
    return unless @batch_id

    log_info "Finishing batch #{@batch_id}"

    database.pgq_finish_batch(@batch_id)
    @batch_id = nil
  end

  def event_retry(event_id, seconds = 0)
    database.pgq_event_retry(@batch_id, event_id, seconds)
  end

  def event_done?(event_id)
    database.pgq_event_done?(@consumer_name, @batch_id, event_id)
  end

  def event_done!(event_id)
    database.pgq_event_done!(@consumer_name, @batch_id, event_id)
  end

  # == log methods

  def log_info(mes)
    @logger.info(mes) if @logger
  end

  def log_error(mes)
    @logger.error(mes) if @logger
  end


end
