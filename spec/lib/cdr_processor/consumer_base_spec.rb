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

  describe '#perform_batch logging' do
    let(:logger) { SemanticLogger::Test::CaptureLogEvents.new }
    let(:consumer) { described_class.new(logger, queue_name, 'spec_consumer') }
    let(:pgq_events) { [{ 'ev_id' => 7, 'ev_type' => 'cdr', 'ev_data' => '{"id":1}' }] }

    before do
      allow(CdrProcessor::CdrDb).to receive_messages(
        pgq_consumer_lock!: true, pgq_next_batch: 42, pgq_get_batch_events: pgq_events, pgq_finish_batch: 1
      )
    end

    context 'when the batch succeeds' do
      before { allow(consumer).to receive(:perform_events) }

      it 'tags every record with batch_id and measures the batch', :aggregate_failures do
        expect(consumer.perform_batch).to eq(1)

        info_events = logger.events.select { |event| event.level == :info }
        expect(info_events.map(&:message)).to eq(['batch(42): events 1', 'batch finished: events 1'])
        expect(logger.events.map(&:named_tags)).to all(include(batch_id: 42))
        expect(info_events.last.duration).to be_a(Float)
      end
    end

    context 'when the batch fails' do
      let(:error) { RuntimeError.new('boom') }

      before do
        allow(consumer).to receive(:perform_events).and_raise(error)
        allow(CdrProcessor::Worker).to receive(:shutdown!)
      end

      it 'tags the error record with batch_id and halts the worker', :aggregate_failures do
        consumer.perform_batch

        record = logger.events.find { |event| event.level == :error }
        expect(record.message).to start_with('<RuntimeError> boom')
        expect(record.named_tags).to include(batch_id: 42)
        expect(CdrProcessor::Worker).to have_received(:shutdown!).with(error)
      end
    end
  end
end
