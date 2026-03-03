# frozen_string_literal: true

require 'bunny-mock'

RSpec.describe CdrProcessor::Processors::CdrAmqp do
  let(:logger) { Logger.new(IO::NULL) }
  let(:cdrs) do
    [
      { id: 1, duration: 2 },
      { id: 2, duration: 2 }
    ]
  end

  let(:consumer) { described_class.new(logger, 'cdr_streaming', 'cdr_amqp', config) }
  let(:config) do
    {
      'connect' => {
        'host' => '127.0.0.1',
        'port' => 5672,
        'ssl' => false,
        'vhost' => '/',
        'user' => 'guest',
        'pass' => 'guest',
        'heartbeat' => :server,
        'frame_max' => 131_072,
        'auth_mechanism' => 'PLAIN'
      }
    }
  end

  let(:connection) { BunnyMock.new }
  let(:channel) { connection.start.channel }
  let(:queue) { channel.queue 'cdr_streaming' }

  before :each do
    allow(CdrProcessor::AmqpFactory.instance).to receive(:get_connection).and_return connection
    allow(consumer).to receive(:event_done?)
    allow(consumer).to receive(:event_done!)
  end

  subject { consumer.perform_group cdrs }

  it 'publishes events to queue' do
    allow(consumer).to receive(:event_done?).and_return false
    expect { subject }.to change { queue.message_count }.by 2
  end

  it 'does not publish events that are consumed already' do
    allow(consumer).to receive(:event_done?).and_return true
    expect { subject }.to change { queue.message_count }.by 0
  end
end
