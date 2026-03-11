# frozen_string_literal: true

# == Schema Information
#
# Table name: billing.currencies
#
#  id   :integer(2)       not null, primary key
#  name :string           not null
#  rate :float            not null
#
# Indexes
#
#  currencies_name_key  (name) UNIQUE
#
RSpec.describe Billing::Currency do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:rate) }
    it { is_expected.to validate_numericality_of(:rate).is_greater_than(0) }

    it { is_expected.to allow_value('USD').for(:name) }
    it { is_expected.to allow_value('EUR').for(:name) }
    it { is_expected.not_to allow_value('INVALID').for(:name) }
    it { is_expected.not_to allow_value('RUB').for(:name) }
    it { is_expected.not_to allow_value('').for(:name) }
  end

  describe '#default?' do
    context 'when id is 0' do
      subject { described_class.new(id: 0) }

      it { is_expected.to be_default }
    end

    context 'when id is not 0' do
      subject { described_class.new(id: 1) }

      it { is_expected.not_to be_default }
    end
  end

  describe 'rate_must_be_one_for_default' do
    context 'when default currency' do
      subject { described_class.new(id: 0, name: 'USD', rate: rate) }

      context 'with rate 1' do
        let(:rate) { 1 }

        it 'is valid' do
          expect(subject).to be_valid
        end
      end

      context 'with rate other than 1' do
        let(:rate) { 2.5 }

        it 'is not valid' do
          expect(subject).not_to be_valid
          expect(subject.errors[:rate]).to include('must be 1 for default currency')
        end
      end
    end

    context 'when non-default currency' do
      subject { described_class.new(id: 1, name: 'EUR', rate: 1.2) }

      it 'is valid' do
        expect(subject).to be_valid
      end
    end
  end

  describe 'prevent_default_destroy' do
    context 'when default currency' do
      let!(:currency) { FactoryBot.create(:currency, :default) }

      it 'prevents deletion' do
        expect { currency.destroy }.not_to change { described_class.count }
        expect(currency.errors[:base]).to include('Default currency cannot be deleted')
      end
    end

    context 'when non-default currency' do
      let!(:currency) { FactoryBot.create(:currency) }

      it 'allows deletion' do
        expect { currency.destroy }.to change { described_class.count }.by(-1)
      end
    end
  end

  describe '.create' do
    subject { described_class.create(create_params) }

    let(:create_params) do
      { name: 'EUR', rate: 1.2 }
    end

    include_examples :creates_record do
      let(:expected_record_attrs) { create_params }
    end

    context 'without name' do
      let(:create_params) { { rate: 1.5 } }

      include_examples :does_not_create_record, errors: {
        name: ["can't be blank", 'is not included in the list']
      }
    end

    context 'without rate' do
      let(:create_params) { { name: 'GBP' } }

      include_examples :does_not_create_record, errors: {
        rate: ["can't be blank", 'must be greater than 0']
      }
    end

    context 'with invalid name' do
      let(:create_params) { { name: 'INVALID', rate: 1.5 } }

      include_examples :does_not_create_record, errors: {
        name: ['is not included in the list']
      }
    end

    context 'with rate <= 0' do
      let(:create_params) { { name: 'GBP', rate: -1 } }

      include_examples :does_not_create_record, errors: {
        rate: ['must be greater than 0']
      }
    end
  end
end
