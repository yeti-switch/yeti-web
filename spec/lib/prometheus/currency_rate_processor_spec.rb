# frozen_string_literal: true

require_relative Rails.root.join('lib/prometheus/currency_rate_processor')

RSpec.describe CurrencyRateProcessor do
  let(:prometheus_client) { instance_double(PrometheusExporter::Client) }

  before do
    allow(PrometheusExporter::Client).to receive(:default).and_return(prometheus_client)
    expect(Thread).to receive(:new).and_yield
  end

  describe '.collect_updates_metric' do
    subject { described_class.collect_updates_metric(3, 'Frankfurter') }

    it 'sends the updates metric labeled by provider' do
      expect(prometheus_client).to receive(:send_json).with(
        { type: 'yeti_currency_rate', updates: 3, metric_labels: { provider: 'Frankfurter' } }
      ).once
      subject
    end
  end

  describe '.collect_error_metric' do
    subject { described_class.collect_error_metric('NBU') }

    it 'sends the errors metric labeled by provider' do
      expect(prometheus_client).to receive(:send_json).with(
        { type: 'yeti_currency_rate', errors: 1, metric_labels: { provider: 'NBU' } }
      ).once
      subject
    end
  end

  describe '.collect_duration_metric' do
    subject { described_class.collect_duration_metric(1.23, 'Bank of Israel') }

    it 'sends the duration metric labeled by provider' do
      expect(prometheus_client).to receive(:send_json).with(
        { type: 'yeti_currency_rate', duration: 1.23, metric_labels: { provider: 'Bank of Israel' } }
      ).once
      subject
    end
  end
end
