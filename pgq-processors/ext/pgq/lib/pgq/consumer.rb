# frozen_string_literal: true

require 'pgq/consumer_base'

# Cute class, for magick inserts and light consume

class Pgq::Consumer < Pgq::ConsumerBase
  # == magick insert events

  def self.method_missing(method_name, *args)
    enqueue(method_name, *args)
  end

  def self.add_event(method_name, *args)
    enqueue(method_name, *args)
  end

  # == magick consume

  attr_reader :params

  def initialize(logger, queue, consumer, params)
    super(logger, queue, consumer)
    @params = params
  end

  def perform(method_name, *args)
    logger.info "Method: #{method_name}, Params: #{args.inspect}"

    send(method_name, *args)
  end
end
