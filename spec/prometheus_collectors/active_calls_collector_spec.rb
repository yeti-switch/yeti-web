# frozen_string_literal: true

require 'prometheus_exporter/server/type_collector'
require Rails.root.join('lib/prometheus/active_calls_collector')

RSpec.describe ActiveCallsCollector, '#metrics' do
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
        { type: 'yeti_ac', total: 2, custom_labels: { a: 'b' } }.deep_stringify_keys
      )
      described_instance.collect(
        { type: 'yeti_ac', total: 3, custom_labels: { b: 'c' } }.deep_stringify_keys
      )
    end

    it 'have only yeti_ac metric' do
      expect(subject.size).to eq(1)
      expect(subject.first).to be_a_gauge(:yeti_ac).with(2, { a: 'b' }).with(3, { b: 'c' })
    end
  end

  context 'with 1 total expired metric and 1 total fresh metric' do
    before do
      travel_monotonic_interval(-35) do
        described_instance.collect(
          { type: 'yeti_ac', total: 2, custom_labels: { a: 'b' } }.deep_stringify_keys
        )
      end
      described_instance.collect(
        { type: 'yeti_ac', total: 3, custom_labels: { b: 'c' } }.deep_stringify_keys
      )
    end

    it 'have only yeti_ac metric' do
      expect(subject.size).to eq(1)
      expect(subject.first).to be_a_gauge(:yeti_ac).with(3, { b: 'c' })
    end
  end

  context 'with expired origination metrics and origination metric' do
    before do
      travel_monotonic_interval(-35) do
        described_instance.collect(
          {
            type: 'yeti_ac',
            account_originated: 10,
            account_originated_unique_src: 20,
            account_originated_unique_dst: 30,
            account_price_originated: 40,
            metric_labels: { account_id: 1230, account_external_id: 456 },
            custom_labels: { b: 'c' }
          }.deep_stringify_keys
        )
      end
      described_instance.collect(
        {
          type: 'yeti_ac',
          account_originated: 1,
          account_originated_unique_src: 2,
          account_originated_unique_dst: 3,
          account_price_originated: 4,
          metric_labels: { account_id: 123, account_external_id: 456 },
          custom_labels: { b: 'c' }
        }.deep_stringify_keys
      )
    end

    it 'have only origination metric' do
      expected = [
        be_a_gauge(:yeti_ac_account_originated)
          .with(1, { b: 'c', account_id: 123, account_external_id: 456 })
          .with(0, { b: 'c', account_id: 1230, account_external_id: 456 }),
        be_a_gauge(:yeti_ac_account_originated_unique_src)
          .with(2, { b: 'c', account_id: 123, account_external_id: 456 })
          .with(0, { b: 'c', account_id: 1230, account_external_id: 456 }),
        be_a_gauge(:yeti_ac_account_originated_unique_dst)
          .with(3, { b: 'c', account_id: 123, account_external_id: 456 })
          .with(0, { b: 'c', account_id: 1230, account_external_id: 456 }),
        be_a_gauge(:yeti_ac_account_price_originated)
          .with(4, { b: 'c', account_id: 123, account_external_id: 456 })
          .with(0, { b: 'c', account_id: 1230, account_external_id: 456 })
      ]
      expect(subject).to match_array(expected)
    end
  end

  context 'with account and total metrics' do
    before do
      described_instance.collect(
        {
          type: 'yeti_ac',
          total: 7,
          custom_labels: { a: 'b' }
        }.deep_stringify_keys
      )
      described_instance.collect(
        {
          type: 'yeti_ac',
          account_originated: 1,
          account_originated_unique_src: 2,
          account_originated_unique_dst: 3,
          account_price_originated: 4,
          metric_labels: { account_id: 123, account_external_id: 456 },
          custom_labels: { b: 'c' }
        }.deep_stringify_keys
      )
      described_instance.collect(
        {
          type: 'yeti_ac',
          account_terminated: 5,
          account_price_terminated: 6,
          metric_labels: { account_id: 321, account_external_id: 543 },
          custom_labels: { c: 'd' }
        }.deep_stringify_keys
      )
    end

    it 'have all metrics' do
      expect(subject).to match_array(
                           [
                             be_a_gauge(:yeti_ac_account_originated)
                               .with(1, { b: 'c', account_id: 123, account_external_id: 456 }),
                             be_a_gauge(:yeti_ac_account_originated_unique_src)
                               .with(2, { b: 'c', account_id: 123, account_external_id: 456 }),
                             be_a_gauge(:yeti_ac_account_originated_unique_dst)
                               .with(3, { b: 'c', account_id: 123, account_external_id: 456 }),
                             be_a_gauge(:yeti_ac_account_price_originated)
                               .with(4, { b: 'c', account_id: 123, account_external_id: 456 }),
                             be_a_gauge(:yeti_ac_account_terminated)
                               .with(5, { c: 'd', account_id: 321, account_external_id: 543 }),
                             be_a_gauge(:yeti_ac_account_price_terminated)
                               .with(6, { c: 'd', account_id: 321, account_external_id: 543 }),
                             be_a_gauge(:yeti_ac).with(7, { a: 'b' })
                           ]
                         )
    end
  end

  context 'when all metrics have expired and not expired values' do
    before do
      travel_monotonic_interval(-35) do
        # expired data for same account_id as fresh data but with different values
        described_instance.collect(
          {
            type: 'yeti_ac',
            total: 17,
            custom_labels: { a: 'b' }
          }.deep_stringify_keys
        )
        described_instance.collect(
          {
            type: 'yeti_ac',
            account_originated: 11,
            account_originated_unique_src: 12,
            account_originated_unique_dst: 13,
            account_price_originated: 14,
            metric_labels: { account_id: 123, account_external_id: 456 },
            custom_labels: { b: 'c' }
          }.deep_stringify_keys
        )
        described_instance.collect(
          {
            type: 'yeti_ac',
            account_terminated: 15,
            account_price_terminated: 16,
            metric_labels: { account_id: 321, account_external_id: 543 },
            custom_labels: { c: 'd' }
          }.deep_stringify_keys
        )

        described_instance.collect(
          {
            type: 'yeti_ac',
            total: 27,
            custom_labels: { a: 'b', c: 'd' }
          }.deep_stringify_keys
        )
        described_instance.collect(
          {
            type: 'yeti_ac',
            account_originated: 21,
            account_originated_unique_src: 22,
            account_originated_unique_dst: 23,
            account_price_originated: 24,
            metric_labels: { account_id: 123, account_external_id: 456 },
            custom_labels: { b: 'cc' }
          }.deep_stringify_keys
        )
        described_instance.collect(
          {
            type: 'yeti_ac',
            account_terminated: 25,
            account_price_terminated: 26,
            metric_labels: { account_id: 3210, account_external_id: 543 },
            custom_labels: { c: 'd' }
          }.deep_stringify_keys
        )
        described_instance.collect(
          {
            type: 'yeti_ac',
            ca: 20,
            ca_price_originated: 50,
            metric_labels: {
              id: 10_123,
              external_id: 999_123,
              external_type: 'term',
              account_id: 1230,
              account_external_id: 456
            },
            custom_labels: { b: 'c' }
          }.deep_stringify_keys
        )
      end
      described_instance.collect(
        {
          type: 'yeti_ac',
          total: 7,
          custom_labels: { a: 'b' }
        }.deep_stringify_keys
      )
      described_instance.collect(
        {
          type: 'yeti_ac',
          account_originated: 1,
          account_originated_unique_src: 2,
          account_originated_unique_dst: 3,
          account_price_originated: 4,
          metric_labels: { account_id: 123, account_external_id: 456 },
          custom_labels: { b: 'c' }
        }.deep_stringify_keys
      )
      described_instance.collect(
        {
          type: 'yeti_ac',
          account_terminated: 5,
          account_price_terminated: 6,
          metric_labels: { account_id: 321, account_external_id: 543 },
          custom_labels: { c: 'd' }
        }.deep_stringify_keys
      )
      described_instance.collect(
        {
          type: 'yeti_ac',
          ca: 5,
          ca_price_originated: 10.25,
          metric_labels: {
            id: 1123,
            external_id: 9123,
            external_type: 'term',
            account_id: 123,
            account_external_id: 456
          },
          custom_labels: { b: 'c' }
        }.deep_stringify_keys
      )
      described_instance.collect(
        {
          type: 'yeti_ac',
          ca: 6,
          ca_price_originated: 10.26,
          metric_labels: {
            id: 1129,
            external_id: nil,
            external_type: nil,
            account_id: 129,
            account_external_id: nil
          },
          custom_labels: { b: 'c' }
        }.deep_stringify_keys
      )
      described_instance.collect(
        {
          type: 'yeti_ac',
          ca: 1,
          ca_price_originated: 10.26,
          metric_labels: {
            id: 1129,
            external_id: nil,
            external_type: '',
            account_id: 129,
            account_external_id: nil
          },
          custom_labels: { b: 'c' }
        }.deep_stringify_keys
      )
    end

    it 'have all metrics' do
      expect(subject).to match_array(
                           [
                             be_a_gauge(:yeti_ac_account_originated)
                               .with(0, { b: 'cc', account_id: 123, account_external_id: 456 })
                               .with(1, { b: 'c', account_id: 123, account_external_id: 456 }),
                             be_a_gauge(:yeti_ac_account_originated_unique_src)
                               .with(0, { b: 'cc', account_id: 123, account_external_id: 456 })
                               .with(2, { b: 'c', account_id: 123, account_external_id: 456 }),
                             be_a_gauge(:yeti_ac_account_originated_unique_dst)
                               .with(0, { b: 'cc', account_id: 123, account_external_id: 456 })
                               .with(3, { b: 'c', account_id: 123, account_external_id: 456 }),
                             be_a_gauge(:yeti_ac_account_price_originated)
                               .with(0, { b: 'cc', account_id: 123, account_external_id: 456 })
                               .with(4, { b: 'c', account_id: 123, account_external_id: 456 }),
                             be_a_gauge(:yeti_ac_account_terminated)
                               .with(0, { c: 'd', account_id: 3210, account_external_id: 543 })
                               .with(5, { c: 'd', account_id: 321, account_external_id: 543 }),
                             be_a_gauge(:yeti_ac_account_price_terminated)
                               .with(0, { c: 'd', account_id: 3210, account_external_id: 543 })
                               .with(6, { c: 'd', account_id: 321, account_external_id: 543 }),
                             be_a_gauge(:yeti_ac)
                               .with(7, { a: 'b' }),
                             be_a_gauge(:yeti_ac_ca)
                               .with(5, { b: 'c', id: 1123, external_id: 9123, external_type: 'term', account_id: 123, account_external_id: 456 })
                               .with(1, { b: 'c', id: 1129, external_id: '', external_type: '', account_id: 129, account_external_id: '' })
                               .with(0, { b: 'c', id: 10_123, external_id: 999_123, external_type: 'term', account_id: 1230, account_external_id: 456 }),
                             be_a_gauge(:yeti_ac_ca_price_originated)
                               .with(10.25, { b: 'c', id: 1123, external_id: 9123, external_type: 'term', account_id: 123, account_external_id: 456 })
                               .with(10.26, { b: 'c', id: 1129, external_id: '', external_type: '', account_id: 129, account_external_id: '' })
                               .with(0, { b: 'c', id: 10_123, external_id: 999_123, external_type: 'term', account_id: 1230, account_external_id: 456 })
                           ]
                         )
    end
  end

  context 'with customer auth metrics' do
    before do
      travel_monotonic_interval(-35) do
        described_instance.collect(
          {
            type: 'yeti_ac',
            ca: 10,
            ca_price_originated: 53.234,
            metric_labels: {
              id: 1001,
              external_id: 123,
              external_type: 'term',
              account_id: 101,
              account_external_id: 101_123
            },
            custom_labels: { b: 'c' }
          }.deep_stringify_keys
        )
        described_instance.collect(
          {
            type: 'yeti_ac',
            ca: 10,
            ca_price_originated: 53.234,
            metric_labels: {
              id: 101,
              external_id: 101_123,
              external_type: 'term',
              account_id: 11,
              account_external_id: 11_123
            },
            custom_labels: { b: 'c' }
          }.deep_stringify_keys
        )
      end
      described_instance.collect(
        {
          type: 'yeti_ac',
          ca: 1,
          ca_price_originated: 1.51,
          metric_labels: {
            id: 101,
            external_id: 101_123,
            external_type: 'term',
            account_id: 11,
            account_external_id: 11_123
          },
          custom_labels: { b: 'c' }
        }.deep_stringify_keys
      )
      described_instance.collect(
        {
          type: 'yeti_ac',
          ca: 2,
          ca_price_originated: 2.52,
          metric_labels: {
            id: 102,
            external_id: 102_123,
            external_type: nil,
            account_id: 11,
            account_external_id: 11_123
          },
          custom_labels: { b: 'c' }
        }.deep_stringify_keys
      )
      described_instance.collect(
        {
          type: 'yeti_ac',
          ca: 3,
          ca_price_originated: 3.53,
          metric_labels: {
            id: 103,
            external_id: nil,
            external_type: nil,
            account_id: 12,
            account_external_id: nil
          },
          custom_labels: { b: 'c' }
        }.deep_stringify_keys
      )
    end

    it 'have only origination metric' do
      expected = [
        be_a_gauge(:yeti_ac_ca)
          .with(0, { b: 'c', id: 1001, external_id: 123, external_type: 'term', account_id: 101, account_external_id: 101_123 })
          .with(1, { b: 'c', id: 101, external_id: 101_123, external_type: 'term', account_id: 11, account_external_id: 11_123 })
          .with(2, { b: 'c', id: 102, external_id: 102_123, external_type: nil, account_id: 11, account_external_id: 11_123 })
          .with(3, { b: 'c', id: 103, external_id: nil, external_type: nil, account_id: 12, account_external_id: nil }),

        be_a_gauge(:yeti_ac_ca_price_originated)
          .with(0, { b: 'c', id: 1001, external_id: 123, external_type: 'term', account_id: 101, account_external_id: 101_123 })
          .with(1.51, { b: 'c', id: 101, external_id: 101_123, external_type: 'term', account_id: 11, account_external_id: 11_123 })
          .with(2.52, { b: 'c', id: 102, external_id: 102_123, external_type: nil, account_id: 11, account_external_id: 11_123 })
          .with(3.53, { b: 'c', id: 103, external_id: nil, external_type: nil, account_id: 12, account_external_id: nil })
      ]
      expect(subject).to match_array(expected)
    end
  end
end
