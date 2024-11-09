# frozen_string_literal: true

require_relative Rails.root.join('lib/prometheus/partition_remove_hook_processor')

RSpec.describe PartitionRemoveHookProcessor do
  describe '.collect_executions_metric' do
    subject { PartitionRemoveHookProcessor.collect_executions_metric }

    it 'responds with correct metrics' do
      expect(subject).to eq({ type: 'ruby_yeti_partition_removing_hook', executions: 1, metric_labels: {} })
    end
  end

  describe '.collect_errors_metric' do
    subject { PartitionRemoveHookProcessor.collect_errors_metric }

    it 'responds with correct metrics' do
      expect(subject).to eq({ type: 'ruby_yeti_partition_removing_hook', errors: 1, metric_labels: {} })
    end
  end

  describe '.collect_duration_metric' do
    subject { PartitionRemoveHookProcessor.collect_duration_metric(13) }

    it 'responds with correct metrics' do
      expect(subject).to eq({ type: 'ruby_yeti_partition_removing_hook', duration: 13, metric_labels: {} })
    end
  end
end
