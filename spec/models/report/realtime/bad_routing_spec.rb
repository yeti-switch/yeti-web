# frozen_string_literal: true

RSpec.describe Report::Realtime::BadRouting do
  describe '.time_interval_eq' do
    # DEFAULT_INTERVAL = 60
    subject { described_class.time_interval_eq(60) }

    context 'record created now' do
      let!(:record) { FactoryBot.create :bad_routing, :with_id, time_start: Time.now.utc }

      it 'should not be present in scope' do
        expect(subject).to_not include(record)
      end
    end

    context 'record created 30 seconds ago' do
      let!(:record) { FactoryBot.create :bad_routing, :with_id, time_start: 30.seconds.ago.utc }

      it 'should not be present in scope' do
        expect(subject).to_not include(record)
      end
    end

    context 'record created 60 seconds ago' do
      let!(:record) { FactoryBot.create :bad_routing, :with_id, time_start: 60.seconds.ago.utc }

      it 'should be present in scope' do
        expect(subject).to include(record)
      end
    end

    context 'record created 90 seconds ago' do
      let!(:record) { FactoryBot.create :bad_routing, :with_id, time_start: 90.seconds.ago.utc }

      it 'should be present in scope' do
        expect(subject).to include(record)
      end
    end

    context 'record created 110 seconds ago' do
      let!(:record) { FactoryBot.create :bad_routing, :with_id, time_start: 110.seconds.ago.utc }

      it 'should be present in scope' do
        expect(subject).to include(record)
      end
    end

    context 'record created 115 seconds ago' do
      let!(:record) { FactoryBot.create :bad_routing, :with_id, time_start: 115.seconds.ago.utc }

      it 'should be present in scope' do
        expect(subject).to include(record)
      end
    end

    context 'record created 130 seconds ago' do
      let!(:record) { FactoryBot.create :bad_routing, :with_id, time_start: 130.seconds.ago.utc }

      it 'should not be present in scope' do
        expect(subject).to_not include(record)
      end
    end

    context 'record created 130 seconds ago with different interval' do
      let!(:record) { FactoryBot.create :bad_routing, :with_id, time_start: 130.seconds.ago.utc }

      it 'should not be present in scope' do
        expect(described_class.time_interval_eq(3600)).to_not include(record)
      end
    end

    context 'record created 1 hour ago' do
      let!(:record) { FactoryBot.create :bad_routing, :with_id, time_start: 3600.seconds.ago.utc }

      it 'should be present in scope' do
        expect(described_class.time_interval_eq(3600)).to include(record)
      end
    end
  end
end
