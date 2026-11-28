# frozen_string_literal: true

RSpec.describe ClickhouseReport::Base do
  describe 'not_eq operation' do
    subject { described_class.operations.fetch(:not_eq).call(:duration, :duration_not_eq, 'Int32') }

    it { is_expected.to eq('duration != {duration_not_eq: Int32}') }
  end

  describe '.parse_datetime_param' do
    subject { described_class.parse_datetime_param(value, 'from-time') }

    shared_examples :parses do |time, query_value|
      it 'returns parsed time and ClickHouse query value' do
        parsed, result = subject
        expect(parsed.to_time).to eq(time)
        expect(result).to eq(query_value)
      end
    end

    shared_examples :invalid do
      it 'raises InvalidParamValue' do
        expect { subject }.to raise_error(ClickhouseReport::Base::InvalidParamValue, 'invalid value from-time')
      end
    end

    context 'with UTC designator and milliseconds' do
      let(:value) { '2026-11-16T00:00:00.000Z' }

      include_examples :parses, Time.utc(2026, 11, 16), '1794787200'
    end

    context 'with numeric offset' do
      let(:value) { '2026-11-16T00:00:00+02:00' }

      include_examples :parses, Time.utc(2026, 11, 15, 22), '1794780000'
    end

    context 'with unix timestamp' do
      let(:value) { '1794787200' }

      include_examples :parses, Time.utc(2026, 11, 16), '1794787200'
    end

    context 'with offset before 1970' do
      let(:value) { '1970-01-01T00:00:00+03:00' }

      include_examples :parses, Time.utc(1969, 12, 31, 21), '0000000000'
    end

    context 'without offset as UTC' do
      let(:value) { '2026-11-16T10:00:00.123' }

      include_examples :parses, Time.utc(2026, 11, 16, 10, 0, 0.123r), '1794823200'
    end

    context 'with date only' do
      let(:value) { '2026-11-16' }

      include_examples :parses, Time.utc(2026, 11, 16), '1794787200'
    end

    context 'with unencoded plus decoded as space' do
      let(:value) { '2026-11-16T10:00:00 02:00' }

      include_examples :invalid
    end

    context 'with named zone' do
      let(:value) { '2026-11-16 10:00:00 Europe/Kyiv' }

      include_examples :invalid
    end

    context 'with partial date' do
      let(:value) { '2026-11' }

      include_examples :invalid
    end

    context 'with impossible date' do
      let(:value) { '2026-02-30' }

      include_examples :invalid
    end

    context 'with garbage' do
      let(:value) { 'invalid' }

      include_examples :invalid
    end

    context 'with array' do
      let(:value) { ['2026-11-16'] }

      include_examples :invalid
    end
  end
end
