# frozen_string_literal: true

require 'prometheus_exporter/server'
require_relative Rails.root.join('lib/prometheus/yeti_cron_job_collector')

RSpec.describe YetiCronJobCollector, '#metrics' do
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

  context 'with data' do
    before do
      described_instance.collect(
        {
          metric_labels: { pid: 123 },
          name: 'SomeName',
          success: true,
          duration: 1.23
        }.deep_stringify_keys
      )
      described_instance.collect(
        {
          metric_labels: { pid: 123 },
          name: 'SomeName',
          success: true,
          duration: 0.03
        }.deep_stringify_keys
      )
      described_instance.collect(
        {
          metric_labels: { pid: 456 },
          name: 'TestJob',
          success: false,
          duration: 30.25
        }.deep_stringify_keys
      )
    end

    it 'returns correct metrics text' do
      is_expected.to match_array [
        'yeti_cron_job_total_count{name="SomeName",pid="123"} 2',
        'yeti_cron_job_total_duration{name="SomeName",pid="123"} 1.26',
        'yeti_cron_job_total_count{name="TestJob",pid="456"} 1',
        'yeti_cron_job_failed_count{name="TestJob",pid="456"} 1',
        'yeti_cron_job_total_duration{name="TestJob",pid="456"} 30.25'
      ]
    end
  end
end
