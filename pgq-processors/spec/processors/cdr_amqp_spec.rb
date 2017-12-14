require 'spec_helper'
require 'uri'
require 'bunny-mock'

require File.join(File.dirname(__FILE__), '../../processors/cdr_amqp')

RSpec.describe CdrAmqp do

  let(:cdrs) do
    [
      { id: 1, duration: 2 },
      { id: 2, duration: 2 }
    ]
  end

  let(:logger)     { double('Logger::Syslog') }
  let(:consumer)   { CdrAmqp.new(logger, 'cdr_streaming', 'cdr_amqp', config) }
  let(:config) do
    {
      connect:
        {
          host: "127.0.0.1",
          port: 5672,
          ssl: false,
          vhost: "/",
          user: "guest",
          pass: "guest",
          heartbeat: :server,
          frame_max: 131072,
          auth_mechanism: "PLAIN"
        }
    }
  end

  let(:connection) { BunnyMock.new }
  let(:channel) { connection.start.channel }
  let(:queue) { channel.queue 'cdr_streaming' }

  before :each do
    allow(logger).to receive(:info)
    allow(logger).to receive(:error)
    allow(AmqpFactory.instance).to receive(:get_connection).and_return connection
    connection.start
  end

  subject { consumer.perform_group cdrs }

  it { expect{subject}.to change{queue.message_count}.by 2 }
end