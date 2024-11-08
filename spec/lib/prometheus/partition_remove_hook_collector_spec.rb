# frozen_string_literal: true

require 'prometheus_exporter/server'
require_relative Rails.root.join('lib/prometheus/partition_remove_hook_collector')

RSpec.describe PartitionRemoveHookCollector, '#metrics' do
  subject { described_instance.metrics.map(&:metric_text).compact_blank.map { |metrics| metrics.split("\n") }.flatten }

  let(:described_instance) { described_class.new }
  let(:data_collect_interval) { 0 }
  let(:data) { [metric_executions, metric_errors, metric_duration] }
  let(:metric_executions) { { executions: 1 } }
  let(:metric_errors) { { errors: 1 } }
  let(:metric_duration) { { duration: 13 } }
  let(:expected_metric_executions_lines) { ['ruby_yeti_partition_removing_hook_executions 1'] }
  let(:expected_metric_errors_lines) { ['ruby_yeti_partition_removing_hook_errors 1'] }
  let(:expected_metric_duarion_lines) { ['ruby_yeti_partition_removing_hook_duration 13'] }

  before do
    travel_process_clock(data_collect_interval) do
      data.map { |obj| described_instance.collect(obj.deep_stringify_keys) }
    end
  end

  context 'when metric_executions, metric_errors and metric_duration collected now' do
    let(:data_collect_interval) { 0 }

    it 'responds with filled metric_executions, metric_errors and metric_duration' do
      expect(subject).to match_array(expected_metric_executions_lines + expected_metric_errors_lines + expected_metric_duarion_lines)
    end
  end

  context 'when metric_executions, metric_errors and metric_duration collected 10 seconds ago' do
    let(:data_collect_interval) { -10 }

    it 'responds with filled metric_executions, metric_errors and metric_duration' do
      expect(subject).to match_array(expected_metric_executions_lines + expected_metric_errors_lines + expected_metric_duarion_lines)
    end
  end

  context 'when metric_executions, metric_errors and metric_duration collected 35 seconds ago' do
    let(:data_collect_interval) { -35 }

    it 'responds with filled metric_executions, metric_errors and metric_duration' do
      expect(subject).to match_array(expected_metric_executions_lines + expected_metric_errors_lines + expected_metric_duarion_lines)
    end
  end

  context 'when metric_executions and metric_duration collected 35 seconds ago and metric_errors collected 2 seconds ago' do
    let(:data_collect_interval) { -35 }
    let(:data) { [metric_executions, metric_duration] }

    before { travel_process_clock(-2) { described_instance.collect(metric_errors.deep_stringify_keys) } }

    it 'responds with empty metric_executions and metric_duration but filled metric_errors' do
      expect(subject).to eq(expected_metric_errors_lines)
    end
  end

  context 'without metrics collected' do
    let(:data) { [] }

    it 'responds without any metrics' do
      expect(subject).to be_empty
    end
  end
end
