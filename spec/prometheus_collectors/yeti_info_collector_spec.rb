# frozen_string_literal: true

require 'prometheus_exporter/server/type_collector'
require Rails.root.join('lib/prometheus/yeti_info_collector.rb')

RSpec.describe YetiInfoCollector, '#metrics' do
  subject do
    described_instance.metrics
  end

  let(:described_instance) { described_class.new }

  context 'without data' do
    it { is_expected.to be_empty }
  end

  context 'with 2 fresh total metrics' do
    before do
      described_instance.collect(
        {
          type: 'yeti_info',
          online: 1,
          custom_labels: { app_type: 'a' },
          metric_labels: { version: '1.1.1' }
        }.deep_stringify_keys
      )

      described_instance.collect(
        {
          type: 'yeti_info',
          online: 1,
          custom_labels: { app_type: 'b' },
          metric_labels: { version: '1.1.2' }
        }.deep_stringify_keys
      )
    end

    it 'have 2 yeti_info_online metrics' do
      expect(subject.size).to eq(1)
      expect(subject.first).to be_a_gauge(:yeti_info_online)
        .with(1, version: '1.1.1', app_type: 'a')
        .with(1, version: '1.1.2', app_type: 'b')
    end
  end

  context 'with 1 expired metric and 1 fresh metric' do
    before do
      travel_monotonic_interval(-35) do
        described_instance.collect(
          {
            type: 'yeti_info',
            online: 1,
            custom_labels: { app_type: 'a' },
            metric_labels: { version: '1.1.1' }
          }.deep_stringify_keys
        )
      end
      described_instance.collect(
        {
          type: 'yeti_info',
          online: 1,
          custom_labels: { app_type: 'b' },
          metric_labels: { version: '1.1.2' }
        }.deep_stringify_keys
      )
    end

    it 'have 1 yeti_info_online metric' do
      expect(subject.size).to eq(1)
      expect(subject.first).to be_a_gauge(:yeti_info_online)
        .with(1, version: '1.1.2', app_type: 'b')
    end
  end

  context 'with 2 expired metrics' do
    before do
      travel_monotonic_interval(-35) do
        described_instance.collect(
          {
            type: 'yeti_info',
            online: 1,
            custom_labels: { app_type: 'a' },
            metric_labels: { version: '1.1.1' }
          }.deep_stringify_keys
        )
        described_instance.collect(
          {
            type: 'yeti_info',
            online: 1,
            custom_labels: { app_type: 'b' },
            metric_labels: { version: '1.1.2' }
          }.deep_stringify_keys
        )
      end
    end

    it 'have no metrics' do
      expect(subject.size).to eq(0)
    end
  end
end
