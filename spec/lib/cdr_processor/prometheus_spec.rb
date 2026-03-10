# frozen_string_literal: true

require 'cdr_processor/prometheus'

RSpec.describe CdrProcessor::Prometheus do
  let(:client) { instance_double(PrometheusExporter::Client) }
  let(:prometheus) { described_class.new(host: 'localhost', port: 9394) }

  before do
    allow(PrometheusExporter::Client).to receive(:new).and_return(client)
  end

  describe '#send_batch_metric' do
    it 'sends correct JSON to prometheus client' do
      allow(client).to receive(:send_json)

      prometheus.send_batch_metric(
        processor_name: 'cdr_billing',
        duration_ms: 150.5,
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
