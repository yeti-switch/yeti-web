# frozen_string_literal: true

require 'bunny-mock'

RSpec.describe CdrProcessor::Processors::CdrAmqp do
  subject { consumer.perform_events(events) }

  let(:logger) { Logger.new(IO::NULL) }
  let(:consumer_name) { 'spec_cdr_amqp' }
  let(:batch_id) { 999_999 }
  let(:consumer) { described_class.new(logger, 'cdr_streaming', consumer_name, config) }
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

  # pgq event ids and cdr ids are different id spaces on purpose: events are
  # acknowledged by the pgq event id, not by the id of the cdr they carry.
  let(:events) do
    [
      build_event(101, id: 1, duration: 2),
      build_event(102, id: 2, duration: 2)
    ]
  end

  def build_event(event_id, data)
    CdrProcessor::Event.new(consumer, 'ev_id' => event_id, 'ev_type' => 'cdr', 'ev_data' => data.to_json)
  end

  def published_messages
    queue.all.map { |message| JSON.parse(message[:message]) }
  end

  def event_done?(event_id)
    CdrProcessor::CdrDb.pgq_event_done?(consumer_name, batch_id, event_id)
  end

  before :each do
    allow(CdrProcessor::AmqpFactory.instance).to receive(:get_connection).and_return connection
    consumer.instance_variable_set(:@batch_id, batch_id)
  end

  it 'publishes events to queue' do
    expect { subject }.to change { queue.message_count }.by 2
  end

  it 'publishes the cdr data of every event' do
    subject
    expect(published_messages).to eq(
      [
        { 'id' => 1, 'duration' => 2 },
        { 'id' => 2, 'duration' => 2 }
      ]
    )
  end

  it 'marks published events as done' do
    subject
    expect([event_done?(101), event_done?(102)]).to eq([true, true])
  end

  context 'when events are consumed already' do
    before { CdrProcessor::CdrDb.pgq_events_done!(consumer_name, batch_id, [101, 102]) }

    it 'does not publish events that are consumed already' do
      expect { subject }.to change { queue.message_count }.by 0
    end
  end

  context 'when a part of the events is consumed already' do
    before { CdrProcessor::CdrDb.pgq_events_done!(consumer_name, batch_id, [101]) }

    it 'publishes the remaining events only' do
      expect { subject }.to change { queue.message_count }.by 1
      expect(published_messages).to eq([{ 'id' => 2, 'duration' => 2 }])
    end

    it 'marks them as done' do
      subject
      expect(event_done?(102)).to be(true)
    end
  end

  context 'when publishing fails' do
    before do
      allow(consumer.instance_variable_get(:@exchange)).to receive(:publish).and_raise(Bunny::ConnectionClosedError, 'closed')
    end

    it 'does not acknowledge the event' do
      expect { subject }.to raise_error(Bunny::ConnectionClosedError)
      expect(event_done?(101)).to be(false)
    end
  end
end
