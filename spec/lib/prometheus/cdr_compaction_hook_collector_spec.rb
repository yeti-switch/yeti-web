# frozen_string_literal: true

require 'prometheus_exporter/server'
require_relative Rails.root.join('lib/prometheus/cdr_compaction_hook_collector')

RSpec.describe CdrCompactionHookCollector, '#metrics' do
  subject { described_instance.metrics.map(&:metric_text).compact_blank.map { |metrics| metrics.split("\n") }.flatten }

  let(:described_instance) { described_class.new(labels) }
  let(:labels) { { 'host' => 'yeti-1' } }
  let(:data) { [metric_executions, metric_success, metric_errors, metric_duration] }
  let(:metric_executions) { { executions: 1 } }
  let(:metric_success) { { success: 1 } }
  let(:metric_errors) { { errors: 1 } }
  let(:metric_duration) { { duration: 13 } }
  let(:expected_metric_executions_lines) { ['yeti_cdr_compaction_hook_executions{host="yeti-1"} 1'] }
  let(:expected_metric_success_lines) { ['yeti_cdr_compaction_hook_success{host="yeti-1"} 1'] }
  let(:expected_metric_errors_lines) { ['yeti_cdr_compaction_hook_errors{host="yeti-1"} 1'] }
  let(:expected_metric_duration_lines) { ['yeti_cdr_compaction_hook_duration{host="yeti-1"} 13'] }
  let(:zero_metric_executions_lines) { ['yeti_cdr_compaction_hook_executions{host="yeti-1"} 0'] }
  let(:zero_metric_success_lines) { ['yeti_cdr_compaction_hook_success{host="yeti-1"} 0'] }
  let(:zero_metric_errors_lines) { ['yeti_cdr_compaction_hook_errors{host="yeti-1"} 0'] }
  let(:zero_metric_duration_lines) { ['yeti_cdr_compaction_hook_duration{host="yeti-1"} 0'] }

  before { data.map { |obj| described_instance.collect(obj.deep_stringify_keys) } }

  context 'when metric_executions, metric_errors and metric_duration collected' do
    it 'responds with filled metric_executions, metric_errors and metric_duration' do
      expect(subject).to match_array(expected_metric_executions_lines + expected_metric_success_lines + expected_metric_errors_lines + expected_metric_duration_lines)
    end
  end

  context 'with 2 metric_executions, 1 metric_errors and 1 metric_duration collected' do
    let(:data) { [metric_executions, metric_executions, metric_success, metric_errors, metric_duration] }
    let(:expected_metric_executions_lines) { ['yeti_cdr_compaction_hook_executions{host="yeti-1"} 2'] }

    it 'responds with filled metric_executions, metric_errors and metric_duration' do
      expect(subject).to match_array(expected_metric_executions_lines + expected_metric_success_lines + expected_metric_errors_lines + expected_metric_duration_lines)
    end
  end

  context 'when metrics are fetched multiple times in a row' do
    it 'should NOT change counter for second call as there no new data collected' do
      expect(subject).to match_array(expected_metric_executions_lines + expected_metric_success_lines + expected_metric_errors_lines + expected_metric_duration_lines)
      expect(subject).to match_array(expected_metric_executions_lines + expected_metric_success_lines + expected_metric_errors_lines + expected_metric_duration_lines)
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
        'yeti_cdr_compaction_hook_executions 1',
        'yeti_cdr_compaction_hook_success 0',
        'yeti_cdr_compaction_hook_errors 0',
        'yeti_cdr_compaction_hook_duration 0'
      )
    end
  end

  describe 'default labels' do
    subject { described_class.new }

    it 'resolves them from PrometheusConfig, matching the client custom_labels' do
      allow(PrometheusConfig).to receive(:default_labels).and_return({ host: :'yeti-2' })
      expect(subject.metrics.map(&:metric_text)).to include('yeti_cdr_compaction_hook_executions{host="yeti-2"} 0')
    end
  end
end
