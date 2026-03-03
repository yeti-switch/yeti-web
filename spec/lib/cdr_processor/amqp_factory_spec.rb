# frozen_string_literal: true

require 'bunny-mock'

RSpec.describe CdrProcessor::AmqpFactory do
  describe '#get_connection' do
    let(:options) do
      {
        host: '127.0.0.1',
        port: 5672,
        ssl: false,
        vhost: '/',
        user: 'guest',
        pass: 'guest',
        heartbeat: :server,
        frame_max: 131_072,
        auth_mechanism: 'PLAIN'
      }
    end

    before :each do
      described_class.instance.instance_variable_set(:@connection, {})
    end

    subject { described_class.instance.get_connection(options) }

    context 'there is no connection' do
      it { expect(subject).to be_a Bunny::Session }
    end

    context 'connection already exists' do
      it 'does not create new connection when there is already one' do
        first_connection = subject
        expect(subject).to eq(first_connection)
      end
    end
  end
end
