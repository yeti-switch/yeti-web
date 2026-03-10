# frozen_string_literal: true

require 'cdr_processor/prometheus'

RSpec.describe CdrProcessor::Prometheus do
  let(:client) { instance_double(PrometheusExporter::Client) }
  let(:prometheus) { described_class.new(host: 'localhost', port: 9394) }

  before do
    allow(PrometheusExporter::Client).to receive(:new).and_return(client)
    allow(client).to receive(:send_json)
  end

  describe '#send_batch_metric' do
    context 'with perform_group_duration_ms' do
      it 'sends all metrics to prometheus client' do
        prometheus.send_batch_metric(
          processor_name: 'cdr_billing',
          duration_ms: 150.5,
          perform_group_duration_ms: 120.3,
          events_count: 10
        )

        expect(client).to have_received(:send_json).with(
          type: 'yeti_cdr_processor',
          metric_labels: { processor: 'cdr_billing' },
          batches: 1,
          events: 10,
          duration: 150.5,
          perform_group_duration: 120.3
        )
      end
    end

    context 'without perform_group_duration_ms' do
      it 'sends metrics without perform_group_duration' do
        prometheus.send_batch_metric(
          processor_name: 'cdr_billing',
          duration_ms: 150.5,
          perform_group_duration_ms: nil,
          events_count: 10
        )

        expect(client).to have_received(:send_json).with(
          type: 'yeti_cdr_processor',
          metric_labels: { processor: 'cdr_billing' },
          batches: 1,
          events: 10,
          duration: 150.5
        )
      end
    end
  end
end
