# frozen_string_literal: true

require 'prometheus_exporter/server'
require_relative Rails.root.join('lib/prometheus/cdr_processor_collector')

RSpec.describe CdrProcessorCollector, '#metrics' do
  subject do
    observers = described_instance.metrics
    gather_metric_text(observers)
  end

  def gather_metric_text(observers)
    observers.map { |observer| observer.metric_text.split("\n") }.flatten
  end

  let(:described_instance) { described_class.new }

  context 'without data' do
    it 'returns no metrics' do
      is_expected.to eq []
    end
  end

  context 'with single batch' do
    before do
      described_instance.collect(
        {
          metric_labels: { processor: 'cdr_billing' },
          batches: 1,
          events: 10,
          duration: 150.5,
          perform_group_duration: 120.3
        }.deep_stringify_keys
      )
    end

    it 'returns correct metrics text' do
      is_expected.to match_array [
        'yeti_cdr_processor_batches_total{processor="cdr_billing"} 1',
        'yeti_cdr_processor_events_total{processor="cdr_billing"} 10',
        'yeti_cdr_processor_duration_ms_total{processor="cdr_billing"} 150.5',
        'yeti_cdr_processor_perform_group_duration_ms_total{processor="cdr_billing"} 120.3'
      ]
    end
  end

  context 'with multiple batches from different processors' do
    before do
      described_instance.collect(
        {
          metric_labels: { processor: 'cdr_billing' },
          batches: 1,
          events: 10,
          duration: 150.5,
          perform_group_duration: 120.3
        }.deep_stringify_keys
      )
      described_instance.collect(
        {
          metric_labels: { processor: 'cdr_billing' },
          batches: 1,
          events: 5,
          duration: 80.3,
          perform_group_duration: 60.1
        }.deep_stringify_keys
      )
      described_instance.collect(
        {
          metric_labels: { processor: 'cdr_stats' },
          batches: 1,
          events: 3,
          duration: 20.0,
          perform_group_duration: 15.0
        }.deep_stringify_keys
      )
    end

    it 'returns correct aggregated metrics text' do
      is_expected.to match_array [
        'yeti_cdr_processor_batches_total{processor="cdr_billing"} 2',
        'yeti_cdr_processor_events_total{processor="cdr_billing"} 15',
        'yeti_cdr_processor_duration_ms_total{processor="cdr_billing"} 230.8',
        'yeti_cdr_processor_perform_group_duration_ms_total{processor="cdr_billing"} 180.4',
        'yeti_cdr_processor_batches_total{processor="cdr_stats"} 1',
        'yeti_cdr_processor_events_total{processor="cdr_stats"} 3',
        'yeti_cdr_processor_duration_ms_total{processor="cdr_stats"} 20.0',
        'yeti_cdr_processor_perform_group_duration_ms_total{processor="cdr_stats"} 15.0'
      ]
    end
  end
end
