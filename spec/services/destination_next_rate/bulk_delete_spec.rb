# frozen_string_literal: true

RSpec.describe DestinationNextRate::BulkDelete do
  subject { described_class.call(next_rate_ids:) }

  let(:next_rate_ids) { next_rates.pluck(:id) }
  let!(:next_rates) { FactoryBot.create_list(:destination_next_rate, 3) }
  let!(:ignored_next_rates) { FactoryBot.create_list(:destination_next_rate, 3) }

  it 'should remove only specific destination next rates' do
    expect { subject }.to change { Routing::DestinationNextRate.count }.by(-3)

    expect(Routing::DestinationNextRate.where(id: next_rates.pluck(:id))).not_to be_exists
    expect(Routing::DestinationNextRate.where(id: ignored_next_rates.pluck(:id))).to be_exists
  end

  context 'when ids is empty' do
    let(:next_rate_ids) { [] }

    it 'should not remove any next_rates' do
      expect { subject }.not_to change { Routing::DestinationNextRate.count }
    end
  end
end
