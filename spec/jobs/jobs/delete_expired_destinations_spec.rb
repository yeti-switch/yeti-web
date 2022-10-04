# frozen_string_literal: true

RSpec.describe Jobs::DeleteExpiredDestinations, '#call', freeze_time: true do
  subject { job.call }

  let(:job) { described_class.new(double) }
  let(:keep_expired_destinations_days) { 5 }
  let!(:expired_destinations) do
    FactoryBot.create_list(:destination, 3, valid_till: valid_till, valid_from: valid_from)
  end
  let!(:next_rates_for_expired_destinations) do
    expired_destinations.map do |destination|
      FactoryBot.create(:destination_next_rate, destination: destination)
    end
  end
  let(:valid_till) { keep_expired_destinations_days.days.ago }
  let(:valid_from) { valid_till - 1.day }

  before do
    allow(YetiConfig).to receive(:keep_expired_destinations_days).and_return(keep_expired_destinations_days)

    # fresh destinations with next rates
    fresh_destinations = FactoryBot.create_list(:destination, 3, valid_from: valid_from, valid_till: valid_till + 1.second)
    fresh_destinations.each { |destination| FactoryBot.create(:destination_next_rate, destination: destination) }
  end

  it 'should call DeleteDestinations service' do
    expect(DeleteDestinations).to receive(:call).with(destination_ids: expired_destinations.map(&:id)).and_call_original
    subject
  end

  it 'should remove expired destinations' do
    expect { subject }.to change { Routing::Destination.count }.by(-expired_destinations.size)

    expired_destinations.each do |destination|
      expect(Routing::Destination).not_to be_exists(destination.id)
    end
  end

  it 'should remove destination next rates' do
    expect { subject }.to change { Routing::DestinationNextRate.count }.by(-next_rates_for_expired_destinations.size)

    next_rates_for_expired_destinations.each do |rates|
      expect(Routing::DestinationNextRate).not_to be_exists(rates.id)
    end
  end

  context 'when keep_expired_destinations_days is nil' do
    let(:keep_expired_destinations_days) { nil }
    let(:valid_till) { 5.days.ago }

    it 'should not call Deletedestinations service' do
      expect(DeleteDestinations).not_to receive(:call)
      subject
    end

    it 'should not remove expired destinations' do
      expect { subject }.not_to change { Routing::Destination.count }
    end

    it 'should not remove destination next rates' do
      expect { subject }.not_to change { Routing::DestinationNextRate.count }
    end
  end

  context 'when keep_expired_destinations_days is empty' do
    let(:keep_expired_destinations_days) { '' }
    let(:valid_till) { 5.days.ago }

    it 'should not call DeleteDestinations service' do
      expect(DeleteDestinations).not_to receive(:call)
      subject
    end

    it 'should not remove expired destinations' do
      expect { subject }.not_to change { Routing::Destination.count }
    end

    it 'should not remove destination next rates' do
      expect { subject }.not_to change { Routing::DestinationNextRate.count }
    end
  end
end
