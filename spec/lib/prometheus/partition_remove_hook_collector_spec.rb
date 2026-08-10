# frozen_string_literal: true

require 'prometheus_exporter/server'
require_relative Rails.root.join('lib/prometheus/partition_remove_hook_collector')

RSpec.describe PartitionRemoveHookCollector, '#metrics' do
  subject { described_instance.metrics.map(&:metric_text).compact_blank.map { |metrics| metrics.split("\n") }.flatten }

  let(:described_instance) { described_class.new(labels, seed_zeros: seed_zeros) }
  let(:seed_zeros) { true }
  let(:labels) { { 'host' => 'yeti-1' } }
  let(:data) { [metric_executions, metric_success, metric_errors, metric_duration] }
  let(:metric_executions) { { executions: 1 } }
  let(:metric_success) { { success: 1 } }
  let(:metric_errors) { { errors: 1 } }
  let(:metric_duration) { { duration: 13 } }
  let(:expected_metric_executions_lines) { ['yeti_partition_removing_hook_executions{host="yeti-1"} 1'] }
  let(:expected_metric_success_lines) { ['yeti_partition_removing_hook_success{host="yeti-1"} 1'] }
  let(:expected_metric_errors_lines) { ['yeti_partition_removing_hook_errors{host="yeti-1"} 1'] }
  let(:expected_metric_duarion_lines) { ['yeti_partition_removing_hook_duration{host="yeti-1"} 13'] }
  let(:zero_metric_executions_lines) { ['yeti_partition_removing_hook_executions{host="yeti-1"} 0'] }
  let(:zero_metric_success_lines) { ['yeti_partition_removing_hook_success{host="yeti-1"} 0'] }
  let(:zero_metric_errors_lines) { ['yeti_partition_removing_hook_errors{host="yeti-1"} 0'] }
  let(:zero_metric_duration_lines) { ['yeti_partition_removing_hook_duration{host="yeti-1"} 0'] }

  before { data.map { |obj| described_instance.collect(obj.deep_stringify_keys) } }

  context 'when metric_executions, metric_errors and metric_duration collected' do
    it 'responds with filled metric_executions, metric_errors and metric_duration' do
      expect(subject).to match_array(expected_metric_executions_lines + expected_metric_success_lines + expected_metric_errors_lines + expected_metric_duarion_lines)
    end
  end

  context 'with 2 metric_executions, 1 metric_errors and 1 metric_duration collected' do
    let(:data) { [metric_executions, metric_executions, metric_success, metric_errors, metric_duration] }
    let(:expected_metric_executions_lines) { ['yeti_partition_removing_hook_executions{host="yeti-1"} 2'] }

    it 'responds with filled metric_executions, metric_errors and metric_duration' do
      expect(subject).to match_array(expected_metric_executions_lines + expected_metric_success_lines + expected_metric_errors_lines + expected_metric_duarion_lines)
    end
  end

  context 'when metrics are fetched multiple times in a row' do
    it 'should NOT change counter for second call as there no new data collected' do
      expect(subject).to match_array(expected_metric_executions_lines + expected_metric_success_lines + expected_metric_errors_lines + expected_metric_duarion_lines)
      expect(subject).to match_array(expected_metric_executions_lines + expected_metric_success_lines + expected_metric_errors_lines + expected_metric_duarion_lines)
    end
  end

  context 'when only metric_executions collected' do
    let(:data) { [metric_executions] }

    it 'responds with filled metric_executions and zero metric_errors and metric_duration' do
      expect(subject).to match_array(expected_metric_executions_lines + zero_metric_success_lines + zero_metric_errors_lines + zero_metric_duration_lines)
    end
  end

  context 'without metrics collected' do
    let(:data) { [] }

    it 'responds with zero metrics, so that they are exported since process start' do
      expect(subject).to match_array(zero_metric_executions_lines + zero_metric_success_lines + zero_metric_errors_lines + zero_metric_duration_lines)
    end
  end

  context 'when sender attaches its own labels' do
    let(:data) { [metric_executions.merge(custom_labels: { host: 'other-host' }, metric_labels: { table: 'cdr' })] }

    it 'ignores them and keeps a single series per counter' do
      expect(subject).to match_array(expected_metric_executions_lines + zero_metric_success_lines + zero_metric_errors_lines + zero_metric_duration_lines)
    end
  end

  context 'without configured labels' do
    let(:labels) { {} }
    let(:data) { [metric_executions] }

    it 'responds with unlabelled metrics' do
      expect(subject).to contain_exactly(
        'yeti_partition_removing_hook_executions 1',
        'yeti_partition_removing_hook_success 0',
        'yeti_partition_removing_hook_errors 0',
        'yeti_partition_removing_hook_duration 0'
      )
    end
  end

  describe 'default labels' do
    subject { described_class.new(seed_zeros: true) }

    it 'resolves them from PrometheusConfig, matching the client custom_labels' do
      allow(PrometheusConfig).to receive(:default_labels).and_return({ host: :'yeti-2' })
      expect(subject.metrics.map(&:metric_text)).to include('yeti_partition_removing_hook_executions{host="yeti-2"} 0')
    end
  end

  context 'when no partition_remove_hook is configured' do
    let(:seed_zeros) { false }
    let(:data) { [] }

    it 'exports no series at all' do
      expect(subject).to be_empty
    end

    it 'still records anything the job does report' do
      described_instance.collect('executions' => 1)
      expect(subject).to contain_exactly('yeti_partition_removing_hook_executions{host="yeti-1"} 1')
    end
  end

  describe 'the zero seed' do
    def seeded_series
      described_class.new(labels).metrics.map(&:metric_text).compact_blank
    end

    it 'is skipped when the hook is not configured' do
      allow(PrometheusConfig).to receive(:partition_remove_hook_configured?).and_return(false)
      expect(seeded_series).to be_empty
    end

    it 'happens when the hook is configured' do
      allow(PrometheusConfig).to receive(:partition_remove_hook_configured?).and_return(true)
      expect(seeded_series).not_to be_empty
    end
  end
end
