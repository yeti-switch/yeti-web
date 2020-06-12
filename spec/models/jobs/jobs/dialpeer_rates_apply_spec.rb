# frozen_string_literal: true

RSpec.describe Jobs::DialpeerRatesApply, type: :cron_job do
  describe '#start!' do
    subject do
      job.start!
      job.run!
    end

    let!(:job) { described_class.take! }
    let!(:rate_plan) { FactoryBot.create(:rateplan) }
    let!(:destination) { FactoryBot.create(:destination, rateplan: rate_plan) }
    let!(:another_destination) { FactoryBot.create(:destination, rateplan: rate_plan) }
    let!(:skipped_destination) { FactoryBot.create(:destination, rateplan: rate_plan) }
    let!(:next_rate) do
      FactoryBot.create :destination_next_rate,
                        destination: destination,
                        apply_time: 1.second.ago,
                        initial_rate: 0.04,
                        next_rate: 0.05,
                        connect_fee: 0.06,
                        initial_interval: 90,
                        next_interval: 120
    end
    let!(:another_next_rate) do
      FactoryBot.create :destination_next_rate,
                        destination: another_destination,
                        apply_time: 5.minutes.ago,
                        initial_rate: 0.07,
                        next_rate: 0.08,
                        connect_fee: 0.09,
                        initial_interval: 5,
                        next_interval: 10
    end

    before do
      FactoryBot.create :destination_next_rate,
                        destination: destination,
                        apply_time: 5.minutes.ago,
                        connect_fee: 1.5,
                        applied: true

      FactoryBot.create :destination_next_rate,
                        destination: destination,
                        apply_time: 5.minutes.from_now,
                        connect_fee: 1.5

      FactoryBot.create :destination_next_rate,
                        destination: skipped_destination,
                        apply_time: 5.minutes.from_now,
                        connect_fee: 2.5
    end

    it 'applies next_rate to destination' do
      subject
      expect(next_rate.reload).to be_applied
      expect(destination.reload).to have_attributes(
        initial_rate: 0.04.to_d,
        next_rate: 0.05.to_d,
        connect_fee: 0.06.to_d,
        initial_interval: 90,
        next_interval: 120
      )
    end

    it 'applies another_next_rate to another_destination' do
      subject
      expect(another_next_rate.reload).to be_applied
      expect(another_destination.reload).to have_attributes(
        initial_rate: 0.07.to_d,
        next_rate: 0.08.to_d,
        connect_fee: 0.09.to_d,
        initial_interval: 5,
        next_interval: 10
      )
    end

    it 'does not change skipped_destination' do
      expect { subject }.to_not change { skipped_destination.reload.attributes }
    end
  end
end
