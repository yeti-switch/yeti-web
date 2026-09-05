# frozen_string_literal: true

RSpec.describe CdrProcessor::ConsumerBase do
  # the advisory key is derived from queue/consumer, so a unique queue keeps
  # examples (and parallel spec processes) from sharing one lock
  let(:queue_name) { "spec_queue_#{SecureRandom.hex(4)}" }
  let(:consumer) { described_class.new(Logger.new(IO::NULL), queue_name, 'spec_consumer') }

  describe '#consumer_lock_ok?' do
    context 'when the lock is free' do
      it 'takes it' do
        expect(consumer.consumer_lock_ok?).to be(true)
      end
    end

    context 'when another instance holds it' do
      before { allow(CdrProcessor::CdrDb).to receive(:pgq_consumer_lock!).and_return(false) }

      it 'is false so the worker idles' do
        expect(consumer.consumer_lock_ok?).to be(false)
      end

      it 'reports the wait only once' do
        expect(consumer.logger).to receive(:info).once
        3.times { consumer.consumer_lock_ok? }
      end
    end

    context 'when the lock was taken earlier' do
      before { consumer.consumer_lock_ok? }

      it 'is still held' do
        expect(consumer.consumer_lock_ok?).to be(true)
      end

      it 'raises once the session lost it' do
        allow(CdrProcessor::CdrDb).to receive(:pgq_consumer_lock?).and_return(false)

        expect { consumer.consumer_lock_ok? }.to raise_error(/Lost the advisory lock/)
      end
    end
  end
end
