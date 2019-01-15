# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Routing::DestinationNextRate, type: :model do
  let!(:rate_plan) { FactoryGirl.create(:rateplan) }
  let!(:destination) { FactoryGirl.create(:destination, destination_attrs) }
  let(:destination_attrs) { { rateplan: rate_plan } }

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

    let!(:record) { FactoryGirl.create(:destination_next_rate, record_attrs) }
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

    let!(:record) { FactoryGirl.create(:destination_next_rate, record_attrs) }
    let(:record_attrs) { { destination: destination } }

    include_examples :changes_records_qty_of, Routing::DestinationNextRate, by: -1
    include_examples :destroys_record
  end
end
