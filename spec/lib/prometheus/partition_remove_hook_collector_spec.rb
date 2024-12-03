# frozen_string_literal: true

require 'prometheus_exporter/server'
require_relative Rails.root.join('lib/prometheus/partition_remove_hook_collector')

RSpec.describe PartitionRemoveHookCollector, '#metrics' do
  subject { described_instance.metrics.map(&:metric_text).compact_blank.map { |metrics| metrics.split("\n") }.flatten }

  let(:described_instance) { described_class.new }
  let(:data) { [metric_executions, metric_errors, metric_duration] }
  let(:metric_executions) { { executions: 1 } }
  let(:metric_errors) { { errors: 1 } }
  let(:metric_duration) { { duration: 13 } }
  let(:expected_metric_executions_lines) { ['yeti_partition_removing_hook_executions 1'] }
  let(:expected_metric_errors_lines) { ['yeti_partition_removing_hook_errors 1'] }
  let(:expected_metric_duarion_lines) { ['yeti_partition_removing_hook_duration 13'] }

  before { data.map { |obj| described_instance.collect(obj.deep_stringify_keys) } }

  context 'when metric_executions, metric_errors and metric_duration collected' do
    it 'responds with filled metric_executions, metric_errors and metric_duration' do
      expect(subject).to match_array(expected_metric_executions_lines + expected_metric_errors_lines + expected_metric_duarion_lines)
    end
  end

  context 'with 2 metric_executions, 1 metric_errors and 1 metric_duration collected' do
    let(:data) { [metric_executions, metric_executions, metric_errors, metric_duration] }
    let(:expected_metric_executions_lines) { ['yeti_partition_removing_hook_executions 2'] }

    it 'responds with filled metric_executions, metric_errors and metric_duration' do
      expect(subject).to match_array(expected_metric_executions_lines + expected_metric_errors_lines + expected_metric_duarion_lines)
    end
  end

  context 'when metrics are fetched multiple times in a row' do
    it 'should NOT change counter for second call as there no new data collected' do
      expect(subject).to match_array(expected_metric_executions_lines + expected_metric_errors_lines + expected_metric_duarion_lines)
      expect(subject).to match_array(expected_metric_executions_lines + expected_metric_errors_lines + expected_metric_duarion_lines)
    end
  end

  context 'without metrics collected' do
    let(:data) { [] }

    it 'responds without any metrics' do
      expect(subject).to be_empty
    end
  end
end
