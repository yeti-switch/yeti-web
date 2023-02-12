# frozen_string_literal: true

RSpec.describe Jobs::DialpeerRatesApply, '#call' do
  subject do
    job.call
  end

  let(:job) { described_class.new(double) }
  let(:rate_groups) do
    FactoryBot.create_list(:rate_group, 5)
  end
  let(:routing_groups) do
    FactoryBot.create_list(:routing_group, 5)
  end

  shared_examples :applies_dialpeer_next_rates do
    it 'applies dialpeer next rates' do
      subject
      dp_next_rates_to_apply.each do |next_rate|
        next_rate.reload
        expect(next_rate).to be_applied
        expect(next_rate.dialpeer).to have_attributes(
                                        current_rate_id: next_rate.id,
                                        initial_rate: next_rate.initial_rate,
                                        next_rate: next_rate.next_rate,
                                        connect_fee: next_rate.connect_fee,
                                        initial_interval: next_rate.initial_interval,
                                        next_interval: next_rate.next_interval
                                      )
      end
    end

    it 'does not change skipped_dialpeers' do
      expect { subject }.to_not change { skipped_dialpeers.map(&:reload).map(&:attributes) }
    end

    it 'does not change skipped_dp_next_rates' do
      expect { subject }.to_not change { skipped_dp_next_rates.map(&:reload).map(&:attributes) }
    end
  end

  shared_examples :applies_destination_next_rates do
    it 'applies destination next rates' do
      subject
      dst_next_rates_to_apply.each do |next_rate|
        next_rate.reload
        expect(next_rate).to be_applied
        expect(next_rate.destination).to have_attributes(
                                           initial_rate: next_rate.initial_rate,
                                           next_rate: next_rate.next_rate,
                                           connect_fee: next_rate.connect_fee,
                                           initial_interval: next_rate.initial_interval,
                                           next_interval: next_rate.next_interval
                                         )
      end
    end

    it 'does not change skipped_destination' do
      expect { subject }.to_not change { skipped_destinations.map(&:reload).map(&:attributes) }
    end

    it 'does not change skipped_dst_next_rates' do
      expect { subject }.to_not change { skipped_dst_next_rates.map(&:reload).map(&:attributes) }
    end
  end

  it 'does not raise error' do
    expect { subject }.not_to raise_error
  end

  context 'when dialpeer next rates exists' do
    let!(:skipped_dialpeers) do
      FactoryBot.create_list(:dialpeer, 2, routing_group: routing_groups.sample)
    end
    let(:dialpeers_qty) { 10 }
    let!(:dialpeers) do
      FactoryBot.create_list(:dialpeer, dialpeers_qty, routing_group: routing_groups.sample)
    end
    let!(:dp_next_rates) do
      dialpeers.map do |dialpeer|
        FactoryBot.create :dialpeer_next_rate,
                          :random,
                          dialpeer: dialpeer,
                          apply_time: 1.second.ago
      end
    end
    let(:dp_next_rates_to_apply) { dp_next_rates }

    let!(:skipped_dp_next_rates) do
      [
        FactoryBot.create(
          :dialpeer_next_rate,
          dialpeer: dialpeers.sample,
          apply_time: 5.minutes.ago,
          connect_fee: 1.5,
          applied: true
        ),
        FactoryBot.create(
          :dialpeer_next_rate,
          dialpeer: dialpeers.sample,
          apply_time: 5.minutes.from_now,
          connect_fee: 1.5
        ),
        FactoryBot.create(
          :dialpeer_next_rate,
          dialpeer: skipped_dialpeers.first,
          apply_time: 5.minutes.from_now,
          connect_fee: 2.5
        )
      ]
    end

    include_examples :applies_dialpeer_next_rates

    context 'when 4 ready dialpeer next rates above RECORDS_LIMIT' do
      before do
        stub_const("#{described_class}::BATCH_SIZE", 5)
        stub_const("#{described_class}::RECORDS_LIMIT", 20)
      end

      let(:dialpeers_qty) { 24 }
      let(:dp_next_rates_to_apply) { dp_next_rates[0..19] }
      let(:skipped_dp_next_rates) { super() + dp_next_rates[20..-1] }
      let(:skipped_dialpeers) { super() + dialpeers[20..-1] }

      include_examples :applies_dialpeer_next_rates
    end

    context 'when 4/9 ready destination next rates above RECORDS_LIMIT' do
      before do
        stub_const("#{described_class}::BATCH_SIZE", 5)
        stub_const("#{described_class}::RECORDS_LIMIT", 20)
      end

      # 15 dp + 5 dst applied, 4 dst skipped
      let(:dialpeers_qty) { 15 }
      let(:destinations_qty) { 9 }
      let!(:destinations) do
        FactoryBot.create_list(:destination, destinations_qty, rate_group: rate_groups.sample)
      end
      let!(:dst_next_rates) do
        destinations.map do |destination|
          FactoryBot.create :destination_next_rate,
                            :random,
                            destination: destination,
                            apply_time: 1.second.ago
        end
      end
      let(:dst_next_rates_to_apply) { dst_next_rates[0..4] }
      let(:skipped_dst_next_rates) { super() + dst_next_rates[5..-1] }
      let(:skipped_destinations) { super() + destinations[5..-1] }

      include_examples :applies_dialpeer_next_rates
    end
  end

  context 'when destination next rates exists' do
    let!(:skipped_destinations) do
      FactoryBot.create_list(:destination, 2, rate_group: rate_groups.sample)
    end
    let(:destinations_qty) { 10 }
    let!(:rate_groups) do
      FactoryBot.create_list(:rate_group, 5)
    end
    let!(:destinations) do
      FactoryBot.create_list(:destination, destinations_qty, rate_group: rate_groups.sample)
    end
    let!(:dst_next_rates) do
      destinations.map do |destination|
        FactoryBot.create :destination_next_rate,
                          :random,
                          destination: destination,
                          apply_time: 1.second.ago
      end
    end
    let(:dst_next_rates_to_apply) { dst_next_rates }

    let!(:skipped_dst_next_rates) do
      [
        FactoryBot.create(
          :destination_next_rate,
          destination: destinations.sample,
          apply_time: 5.minutes.ago,
          connect_fee: 1.5,
          applied: true
        ),
        FactoryBot.create(
          :destination_next_rate,
          destination: destinations.sample,
          apply_time: 5.minutes.from_now,
          connect_fee: 1.5
        ),
        FactoryBot.create(
          :destination_next_rate,
          destination: skipped_destinations.first,
          apply_time: 5.minutes.from_now,
          connect_fee: 2.5
        )
      ]
    end

    include_examples :applies_destination_next_rates

    context 'when there are more next rates than RECORDS_LIMIT' do
      before do
        stub_const("#{described_class}::BATCH_SIZE", 5)
        stub_const("#{described_class}::RECORDS_LIMIT", 20)
      end

      let(:destinations_qty) { 24 }
      let(:dst_next_rates_to_apply) { dst_next_rates[0..19] }
      let(:skipped_dst_next_rates) { super() + dst_next_rates[20..-1] }
      let(:skipped_destinations) { super() + destinations[20..-1] }

      include_examples :applies_destination_next_rates
    end
  end
end
