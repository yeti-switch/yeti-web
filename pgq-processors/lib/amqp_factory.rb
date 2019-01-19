# frozen_string_literal: true

require 'bunny'

class AmqpFactory
  include Singleton

  def initialize
    @connection = {}
  end

  def get_connection(options)
    return @connection[options] if @connection[options].present?

    new_connection = Bunny.new(options)
    @connection[options] = new_connection
    new_connection
  end
end
