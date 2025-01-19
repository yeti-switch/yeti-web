# frozen_string_literal: true

require_relative Rails.root.join('lib/prometheus/partition_remove_hook_processor')

RSpec.describe PartitionRemoveHookProcessor do
  let(:prometheus_client) { instance_double(PrometheusExporter::Client) }

  before do
    allow(PrometheusExporter::Client).to receive(:default).and_return(prometheus_client)
    expect(Thread).to receive(:new).and_yield
  end

  describe '.collect_executions_metric' do
    subject { PartitionRemoveHookProcessor.collect_executions_metric }

    it 'responds with correct metrics' do
      expect(prometheus_client).to receive(:send_json).with(
        { type: 'yeti_partition_removing_hook', executions: 1, metric_labels: {} }
      ).once
      subject
    end
  end

  describe '.collect_errors_metric' do
    subject { PartitionRemoveHookProcessor.collect_errors_metric }

    it 'responds with correct metrics' do
      expect(prometheus_client).to receive(:send_json).with(
        { type: 'yeti_partition_removing_hook', errors: 1, metric_labels: {} }
      ).once
      subject
    end
  end

  describe '.collect_duration_metric' do
    subject { PartitionRemoveHookProcessor.collect_duration_metric(13) }

    it 'responds with correct metrics' do
      expect(prometheus_client).to receive(:send_json).with(
        { type: 'yeti_partition_removing_hook', duration: 13, metric_labels: {} }
      ).once
      subject
    end
  end
end
