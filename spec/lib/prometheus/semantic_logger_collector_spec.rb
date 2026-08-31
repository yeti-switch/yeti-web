# frozen_string_literal: true

require 'prometheus_exporter/server'
require_relative Rails.root.join('lib/prometheus/semantic_logger_collector')

RSpec.describe SemanticLoggerCollector, '#metrics' do
  subject do
    described_instance.metrics.flat_map { |observer| observer.metric_text.split("\n") }
  end

  let(:described_instance) { described_class.new }

  def collect(payload)
    described_instance.collect(payload.deep_stringify_keys)
  end

  context 'without data' do
    it 'returns no metrics' do
      is_expected.to eq []
    end
  end

  context 'with one queue' do
    before do
      collect(
        metric_labels: { pid: 111, app_type: 'puma', queue: 'processor' },
        queue_size: 3, max_queue_size: 10_000, thread_active: 1, processed: 42, dropped: 0
      )
    end

    it 'returns a series per field' do
      is_expected.to match_array [
        'yeti_log_queue_size{pid="111",app_type="puma",queue="processor"} 3',
        'yeti_log_queue_max_size{pid="111",app_type="puma",queue="processor"} 10000',
        'yeti_log_thread_active{pid="111",app_type="puma",queue="processor"} 1',
        'yeti_log_processed_total{pid="111",app_type="puma",queue="processor"} 42',
        'yeti_log_dropped_total{pid="111",app_type="puma",queue="processor"} 0'
      ]
    end
  end

  context 'with the same queue of two processes' do
    before do
      collect(metric_labels: { pid: 111, queue: 'processor' }, queue_size: 3, processed: 42, dropped: 0)
      collect(metric_labels: { pid: 222, queue: 'processor' }, queue_size: 900, processed: 7, dropped: 5)
    end

    it 'keeps them apart, so that puma workers do not overwrite each other' do
      is_expected.to include(
        'yeti_log_queue_size{pid="111",queue="processor"} 3',
        'yeti_log_queue_size{pid="222",queue="processor"} 900'
      )
    end
  end

  context 'when a process reports twice' do
    before do
      collect(metric_labels: { pid: 111, queue: 'processor' }, queue_size: 3, processed: 42, dropped: 0)
      collect(metric_labels: { pid: 111, queue: 'processor' }, queue_size: 8, processed: 90, dropped: 0)
    end

    # The counters are cumulative in the process already, so the collector sets them to
    # the reported value instead of adding it to what it has.
    it 'exports the last reported value and not the sum' do
      is_expected.to include(
        'yeti_log_queue_size{pid="111",queue="processor"} 8',
        'yeti_log_processed_total{pid="111",queue="processor"} 90'
      )
    end
  end

  context 'when the data is older than max_metric_age' do
    before do
      # The clock of #collect and the clock of #metrics, one call each.
      allow(Process).to receive(:clock_gettime).and_return(0, described_class.max_metric_age + 1)
      collect(metric_labels: { pid: 111, queue: 'processor' }, queue_size: 3)
    end

    it 'stops exporting the process that went away' do
      is_expected.to eq []
    end
  end
end
