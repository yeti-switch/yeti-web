# frozen_string_literal: true

RSpec.describe CdrProcessor::Worker do
  let(:logger) { Logger.new(IO::NULL) }
  let(:processor) { double('processor', class: double(name: 'CdrProcessor::Processors::CdrBilling')) }
  let(:prometheus) { nil }
  let(:worker) do
    described_class.new(
      logger: logger,
      processor: processor,
      processor_name: 'cdr_billing',
      prometheus: prometheus
    )
  end

  after do
    described_class.interrupted = false
    described_class.graceful_exit = true
  end

  describe '#process_batch' do
    context 'without prometheus' do
      it 'returns processed count from processor' do
        allow(processor).to receive(:perform_batch).and_return(5)

        expect(worker.process_batch).to eq 5
      end
    end

    context 'with prometheus' do
      let(:prometheus) { instance_double(CdrProcessor::Prometheus) }

      before do
        allow(prometheus).to receive(:send_batch_metric)
      end

      context 'when batch has events' do
        before do
          allow(processor).to receive(:perform_batch).and_return(5)
        end

        it 'sends metrics to prometheus' do
          worker.process_batch

          expect(prometheus).to have_received(:send_batch_metric).with(
            processor_name: 'cdr_billing',
            duration_ms: a_value > 0,
            events_count: 5
          )
        end
      end

      context 'when batch is empty' do
        before do
          allow(processor).to receive(:perform_batch).and_return(0)
        end

        it 'does not send metrics to prometheus' do
          worker.process_batch

          expect(prometheus).not_to have_received(:send_batch_metric)
        end
      end

      context 'when no batch available' do
        before do
          allow(processor).to receive(:perform_batch).and_return(nil)
        end

        it 'does not send metrics to prometheus' do
          worker.process_batch

          expect(prometheus).not_to have_received(:send_batch_metric)
        end
      end
    end
  end
end
