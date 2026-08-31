# frozen_string_literal: true

require_relative Rails.root.join('lib/prometheus/semantic_logger_processor')

RSpec.describe SemanticLoggerProcessor do
  let(:client) { instance_double(PrometheusExporter::Client, send_json: nil) }
  let(:payloads) do
    [
      { type: 'yeti_log', metric_labels: { component: 'puma', pid: 1, queue: 'processor' }, queue_size: 0 },
      { type: 'yeti_log', metric_labels: { component: 'puma', pid: 1, queue: 'es' }, queue_size: 7 }
    ]
  end

  # The processor reports from a thread of its own, so the examples wait for the report
  # to arrive instead of sleeping for a guessed interval.
  let(:reported) { Queue.new }

  before do
    described_class.logger = SemanticLogger['spec']
    allow(YetiLogStats).to receive(:metrics).and_return(payloads)
    allow(client).to receive(:send_json) { |payload| reported << payload }
  end

  after { described_class.stop }

  describe '.start' do
    it 'reports every payload of YetiLogStats' do
      described_class.start(client: client, frequency: 60)
      expect([reported.pop(timeout: 5), reported.pop(timeout: 5)]).to eq(payloads)
    end

    context 'when one payload fails to be sent' do
      before do
        allow(CaptureError).to receive(:capture)
        call_count = 0
        allow(client).to receive(:send_json) do |payload|
          call_count += 1
          raise StandardError, 'boom' if call_count == 1

          reported << payload
        end
      end

      # The queues are reported one payload each, so a queue that cannot be reported
      # must not hide the state of the next one.
      it 'still reports the rest' do
        described_class.start(client: client, frequency: 60)
        expect(reported.pop(timeout: 5)).to eq(payloads.last)
      end
    end

    it 'passes the given labels on' do
      described_class.start(client: client, frequency: 60, labels: { processor: 'cdr_billing' })
      reported.pop(timeout: 5)
      expect(YetiLogStats).to have_received(:metrics).with(processor: 'cdr_billing')
    end

    it 'is running afterwards' do
      described_class.start(client: client, frequency: 60)
      expect(described_class).to be_running
    end

    context 'when the reporting raises' do
      let(:captured) { Queue.new }

      before do
        allow(YetiLogStats).to receive(:metrics).and_raise(StandardError, 'boom')
        allow(CaptureError).to receive(:capture) { |error, **| captured << error }
      end

      # A process must not lose its reporting thread to a broken exporter.
      it 'keeps the thread alive' do
        described_class.start(client: client, frequency: 60)
        expect(captured.pop(timeout: 5)).to be_a(StandardError)
        expect(described_class).to be_running
      end
    end
  end

  describe '.stop' do
    it 'stops a running processor' do
      described_class.start(client: client, frequency: 60)
      described_class.stop
      expect(described_class).not_to be_running
    end
  end
end
