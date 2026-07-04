# frozen_string_literal: true

require 'prometheus_exporter/server'
require_relative Rails.root.join('lib/prometheus/currency_rate_collector')

RSpec.describe CurrencyRateCollector, '#metrics' do
  subject { described_instance.metrics.map(&:metric_text).compact_blank.map { |m| m.split("\n") }.flatten }

  let(:described_instance) { described_class.new }
  let(:labels) { { metric_labels: { provider: 'Frankfurter' } } }
  let(:data) { [metric_updates, metric_errors, metric_duration] }
  let(:metric_updates) { { updates: 2, **labels } }
  let(:metric_errors) { { errors: 1, **labels } }
  let(:metric_duration) { { duration: 1.5, **labels } }

  before { data.map { |obj| described_instance.collect(obj.deep_stringify_keys) } }

  it 'exposes updates, errors and duration labeled by provider' do
    expect(subject).to include(
      'yeti_currency_rate_updates{provider="Frankfurter"} 2',
      'yeti_currency_rate_errors{provider="Frankfurter"} 1',
      'yeti_currency_rate_duration{provider="Frankfurter"} 1.5'
    )
  end

  context 'with two update batches collected' do
    let(:data) { [metric_updates, metric_updates, metric_errors] }

    it 'accumulates the updates counter' do
      expect(subject).to include('yeti_currency_rate_updates{provider="Frankfurter"} 4')
    end
  end

  context 'when duration is collected multiple times' do
    let(:data) { [{ duration: 1.5, **labels }, { duration: 2.0, **labels }] }

    it 'accumulates the duration counter' do
      expect(subject).to include('yeti_currency_rate_duration{provider="Frankfurter"} 3.5')
    end
  end
end
