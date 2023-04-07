# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.destination_next_rates
#
#  id               :bigint(8)        not null, primary key
#  applied          :boolean          default(FALSE), not null
#  apply_time       :timestamptz
#  connect_fee      :decimal(, )      not null
#  initial_interval :integer(2)       not null
#  initial_rate     :decimal(, )      not null
#  next_interval    :integer(2)       not null
#  next_rate        :decimal(, )      not null
#  created_at       :timestamptz
#  updated_at       :timestamptz
#  destination_id   :bigint(8)        not null
#  external_id      :bigint(8)
#
# Foreign Keys
#
#  destination_next_rates_destination_id_fkey  (destination_id => destinations.id)
#

RSpec.describe Routing::DestinationNextRate, type: :model do
  let!(:rate_group) { FactoryBot.create(:rate_group) }
  let!(:destination) { FactoryBot.create(:destination, destination_attrs) }
  let(:destination_attrs) { { rate_group: rate_group } }

  describe '.create' do
    subject do
      described_class.create(create_params)
    end

    let(:create_params) do
      {
        destination_id: destination.id,
        initial_rate: 0.01,
        next_rate: 0.01,
        initial_interval: 60,
        next_interval: 60,
        connect_fee: 0,
        apply_time: 1.hour.from_now
      }
    end
    let(:default_params) do
      { applied: false }
    end

    include_examples :creates_record do
      let(:expected_record_attrs) { create_params.merge(default_params) }
    end

    include_examples :changes_records_qty_of, Routing::DestinationNextRate, by: 1
  end

  describe '#update' do
    subject do
      record.update(update_params)
    end

    let!(:record) { FactoryBot.create(:destination_next_rate, record_attrs) }
    let(:record_attrs) { { destination: destination } }

    context 'change initial_rate' do
      let(:update_params) { { initial_rate: 0.99 } }

      include_examples :updates_record
    end
  end

  describe '#destroy' do
    subject do
      record.destroy
    end

    let!(:record) { FactoryBot.create(:destination_next_rate, record_attrs) }
    let(:record_attrs) { { destination: destination } }

    include_examples :changes_records_qty_of, Routing::DestinationNextRate, by: -1
    include_examples :destroys_record
  end
end
