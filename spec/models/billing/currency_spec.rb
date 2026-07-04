# frozen_string_literal: true

# == Schema Information
#
# Table name: billing.currencies
#
#  id               :integer(2)       not null, primary key
#  name             :string           not null
#  rate             :float            not null
#  rate_provider_id :integer(2)
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

    it { is_expected.to allow_value('EUR').for(:name) }
    it { is_expected.to allow_value('GBP').for(:name) }
    it { is_expected.not_to allow_value('INVALID').for(:name) }
    it { is_expected.not_to allow_value('RUB').for(:name) }
    it { is_expected.not_to allow_value('').for(:name) }

    it { is_expected.to allow_value(nil).for(:rate_provider_id) }
    it { is_expected.to allow_value(Billing::CurrencyRateProvider::FRANKFURTER).for(:rate_provider_id) }
    it { is_expected.to allow_value(Billing::CurrencyRateProvider::BANK_OF_ISRAEL).for(:rate_provider_id) }
    it { is_expected.to allow_value(Billing::CurrencyRateProvider::NBU).for(:rate_provider_id) }
    it { is_expected.not_to allow_value(999).for(:rate_provider_id) }
  end

  describe 'rate_provider_must_be_empty_for_default' do
    context 'when default currency' do
      let(:default_currency) { described_class.find(0) }

      it 'is not valid with rate provider' do
        default_currency.rate_provider_id = Billing::CurrencyRateProvider::FRANKFURTER
        expect(default_currency).not_to be_valid
        expect(default_currency.errors[:rate_provider_id]).to include('must be empty for default currency')
      end
    end

    context 'when non-default currency' do
      subject { described_class.new(id: 1, name: 'EUR', rate: 1.2, rate_provider_id: Billing::CurrencyRateProvider::FRANKFURTER) }

      it 'is valid' do
        expect(subject).to be_valid
      end
    end
  end

  describe 'rate_provider_must_support_currency' do
    subject { described_class.new(id: 1, name: name, rate: 1.2, rate_provider_id: Billing::CurrencyRateProvider::FRANKFURTER) }

    context 'when currency is supported by provider' do
      let(:name) { 'EUR' }

      it 'is valid' do
        expect(subject).to be_valid
      end
    end

    context 'when currency is not supported by provider' do
      let(:name) { 'UAH' }

      it 'is not valid' do
        expect(subject).not_to be_valid
        expect(subject.errors[:rate_provider_id]).to include('Frankfurter does not support UAH')
      end
    end

    context 'when provider does not support system currency' do
      let(:name) { 'EUR' }

      before do
        allow(CurrencyRates::Providers::Frankfurter).to receive(:supports?).and_call_original
        allow(CurrencyRates::Providers::Frankfurter).to receive(:supports?).with('USD').and_return(false)
      end

      it 'is not valid' do
        expect(subject).not_to be_valid
        expect(subject.errors[:rate_provider_id]).to include('Frankfurter does not support system currency USD required for cross rates')
      end
    end
  end

  describe 'used_rate_providers_must_support_system_currency' do
    let(:default_currency) { described_class.find(0) }
    let!(:ils) { FactoryBot.create(:currency, name: 'ILS', rate: 0.3, rate_provider_id: Billing::CurrencyRateProvider::BANK_OF_ISRAEL) }

    context 'when renaming to a name unsupported by used providers' do
      it 'is not valid' do
        default_currency.name = 'UAH'
        expect(default_currency).not_to be_valid
        expect(default_currency.errors[:name])
          .to include('is not supported as system currency by used rate provider(s): Bank of Israel')
      end
    end

    context 'when renaming to a name supported by used providers' do
      it 'is valid' do
        default_currency.name = 'GBP'
        expect(default_currency).to be_valid
      end
    end
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
      let(:default_currency) { described_class.find(0) }

      context 'with rate 1' do
        it 'is valid' do
          default_currency.rate = 1
          expect(default_currency).to be_valid
        end
      end

      context 'with rate other than 1' do
        it 'is not valid' do
          default_currency.rate = 2.5
          expect(default_currency).not_to be_valid
          expect(default_currency.errors[:rate]).to include('must be 1 for default currency')
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
      let!(:currency) { described_class.find(0) }

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
        rate: ["can't be blank", 'is not a number']
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
