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
                                   .with(7, { a: 'b' })
                             ]
                           )
    end
  end
end
