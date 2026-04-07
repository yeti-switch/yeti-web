# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.gateway_throttling_profiles
#
#  id              :integer(2)       not null, primary key
#  codes           :string           not null, is an Array
#  minimum_calls   :integer(2)       default(20), not null
#  name            :string           not null
#  threshold_end   :float(24)        not null
#  threshold_start :float(24)        not null
#  window          :integer(2)       not null
#
# Indexes
#
#  gateway_throttling_profiles_name_key  (name) UNIQUE
#
RSpec.describe Equipment::GatewayThrottlingProfile, type: :model do
  describe '.create' do
    subject do
      described_class.create(create_params)
    end

    let(:create_params) do
      {
        name: 'test profile',
        codes: [Equipment::GatewayThrottlingProfile::CODE_503],
        threshold_start: 60,
        threshold_end: 90,
        window: 60
      }
    end

    include_examples :creates_record
    include_examples :changes_records_qty_of, described_class, by: 1
    include_examples :increments_system_state, 'gateways_cache'
    include_examples :increments_system_state, 'bleg_gateways_cache'
  end

  describe '#update' do
    subject do
      record.update(update_params)
    end

    let!(:record) { FactoryBot.create(:gateway_throttling_profile) }
    let(:update_params) { { threshold_start: 70 } }

    include_examples :updates_record
    include_examples :increments_system_state, 'gateways_cache'
    include_examples :increments_system_state, 'bleg_gateways_cache'
  end

  describe '#destroy' do
    subject do
      record.destroy
    end

    let!(:record) { FactoryBot.create(:gateway_throttling_profile) }

    include_examples :destroys_record
    include_examples :changes_records_qty_of, described_class, by: -1
    include_examples :increments_system_state, 'gateways_cache'
    include_examples :increments_system_state, 'bleg_gateways_cache'
  end
end
