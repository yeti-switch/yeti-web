# frozen_string_literal: true

RSpec.describe Worker::ScheduleRateChanges, type: :job do
  subject { described_class.perform_now(ids_sql, rate_attrs) }

  let!(:destinations) { FactoryBot.create_list(:destination, 2) }

  let(:ids_sql) do
    <<-SQL.squish
        SELECT "class4"."destinations"."id" FROM "class4"."destinations" WHERE "class4"."destinations"."id" IN (#{destinations.pluck(:id).join(', ')})
    SQL
  end
  let(:rate_attrs) do
    {
      apply_time:,
      initial_interval:,
      initial_rate:,
      next_interval:,
      next_rate:,
      connect_fee:
    }
  end
  let(:apply_time) { 1.month.from_now.to_date }
  let(:initial_interval) { 60 }
  let(:initial_rate) { 0.01 }
  let(:next_interval) { 30 }
  let(:next_rate) { 0.02 }
  let(:connect_fee) { 0.03 }

  before do
    # not affected destinations
    FactoryBot.create_list(:destination, 3)
  end

  it 'should call Destination::ScheduleRateChanges service' do
    expect(Destination::ScheduleRateChanges).to receive(:call).with(
      ids: match_array(destinations.pluck(:id)),
      apply_time:,
      initial_interval:,
      initial_rate:,
      next_interval:,
      next_rate:,
      connect_fee:
    ).and_call_original

    expect { subject }.to change { Routing::DestinationNextRate.count }.by(destinations.size)
  end

  context 'when Destination::ScheduleRateChanges service raise error' do
    let(:error) { Destination::ScheduleRateChanges::Error.new('some error') }

    before do
      allow(Destination::ScheduleRateChanges).to receive(:call).with(
        ids: match_array(destinations.pluck(:id)),
        apply_time:,
        initial_interval:,
        initial_rate:,
        next_interval:,
        next_rate:,
        connect_fee:
      ).and_raise(error)
    end

    it 'raises error' do
      expect { subject }.to raise_error(error)
    end
  end
end
