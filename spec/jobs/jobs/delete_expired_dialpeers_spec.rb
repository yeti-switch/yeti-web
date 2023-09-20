# frozen_string_literal: true

RSpec.describe Jobs::DeleteExpiredDialpeers, '#call', freeze_time: true do
  subject { job.call }

  let(:job) { described_class.new(double) }
  let(:keep_expired_dialpeers_days) { 5 }
  let!(:expired_dialpeers) do
    FactoryBot.create_list(:dialpeer, 3, valid_till: valid_till, valid_from: valid_from)
  end
  let!(:next_rates_for_expired_dialpeers) do
    expired_dialpeers.map do |dialpeer|
      FactoryBot.create(:dialpeer_next_rate, dialpeer: dialpeer)
    end
  end
  let(:valid_till) { keep_expired_dialpeers_days.days.ago }
  let(:valid_from) { valid_till - 1.day }

  before do
    allow(YetiConfig).to receive(:keep_expired_dialpeers_days).and_return(keep_expired_dialpeers_days)

    # fresh dialpeers with next rates
    fresh_dialpeers = FactoryBot.create_list(:dialpeer, 3, valid_from: valid_from, valid_till: valid_till + 1.second)
    fresh_dialpeers.each { |dialpeer| FactoryBot.create(:dialpeer_next_rate, dialpeer: dialpeer) }
  end

  it 'should call DeleteDialpeers service' do
    expect(DeleteDialpeers).to receive(:call).with(:dialpeer_ids => contain_exactly(*expired_dialpeers.map(&:id))).and_call_original
    subject
  end

  it 'should remove expired dialpeers' do
    expect { subject }.to change { Dialpeer.count }.by(-expired_dialpeers.size)

    expired_dialpeers.each do |dialpeer|
      expect(Dialpeer).not_to be_exists(dialpeer.id)
    end
  end

  it 'should remove dialpeer next rates' do
    expect { subject }.to change { DialpeerNextRate.count }.by(-next_rates_for_expired_dialpeers.size)

    next_rates_for_expired_dialpeers.each do |rates|
      expect(DialpeerNextRate).not_to be_exists(rates.id)
    end
  end

  context 'when keep_expired_dialpeers_days is nil' do
    let(:keep_expired_dialpeers_days) { nil }
    let(:valid_till) { 5.days.ago }

    it 'should not call DeleteDialpeers service' do
      expect(DeleteDialpeers).not_to receive(:call)
      subject
    end

    it 'should not remove expired dialpeers' do
      expect { subject }.not_to change { Dialpeer.count }
    end

    it 'should not remove dialpeer next rates' do
      expect { subject }.not_to change { DialpeerNextRate.count }
    end
  end

  context 'when keep_expired_dialpeers_days is empty' do
    let(:keep_expired_dialpeers_days) { '' }
    let(:valid_till) { 5.days.ago }

    it 'should not call DeleteDialpeers service' do
      expect(DeleteDialpeers).not_to receive(:call)
      subject
    end

    it 'should not remove expired dialpeers' do
      expect { subject }.not_to change { Dialpeer.count }
    end

    it 'should not remove dialpeer next rates' do
      expect { subject }.not_to change { DialpeerNextRate.count }
    end
  end
end
