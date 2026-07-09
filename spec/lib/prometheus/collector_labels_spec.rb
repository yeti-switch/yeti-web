# frozen_string_literal: true

require_relative Rails.root.join('lib/prometheus/collector_labels')

RSpec.describe CollectorLabels, '.call' do
  subject { described_class.call }

  context 'when default_labels are configured' do
    before { allow(PrometheusConfig).to receive(:default_labels).and_return({ host: :'yeti-1' }) }

    it 'stringifies names and values, matching the client custom_labels' do
      expect(subject).to eq({ 'host' => 'yeti-1' })
    end
  end

  context 'when default_labels is a Config::Options' do
    before { allow(PrometheusConfig).to receive(:default_labels).and_return(Config::Options.new.merge!(host: 'yeti-1')) }

    it 'converts it to a plain hash' do
      expect(subject).to eq({ 'host' => 'yeti-1' })
    end
  end

  context 'when default_labels are not configured' do
    before { allow(PrometheusConfig).to receive(:default_labels).and_return(nil) }

    it { is_expected.to eq({}) }
  end

  context 'when YetiConfig is unavailable' do
    before { allow(PrometheusConfig).to receive(:default_labels).and_raise(NameError, 'uninitialized constant YetiConfig') }

    it 'falls back to unlabelled metrics instead of preventing the exporter from starting' do
      expect { subject }.to_not raise_error
      expect(subject).to eq({})
    end
  end
end
