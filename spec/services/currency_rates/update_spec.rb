# frozen_string_literal: true

RSpec.describe CurrencyRates::Update, '.call' do
  subject do
    described_class.call
  end

  let!(:eur) { FactoryBot.create(:currency, name: 'EUR', rate: 1.0, rate_provider_id: Billing::CurrencyRateProvider::FRANKFURTER) }
  let!(:jpy) { FactoryBot.create(:currency, name: 'JPY', rate: 1.0, rate_provider_id: Billing::CurrencyRateProvider::FRANKFURTER) }
  let!(:manual_currency) { FactoryBot.create(:currency, name: 'GBP', rate: 1.5, rate_provider_id: nil) }

  let(:request_stub) do
    stub_request(:get, 'https://api.frankfurter.dev/v1/latest?base=USD')
      .to_return(
        status: 200,
        headers: { 'Content-Type' => 'application/json' },
        body: { base: 'USD', date: '2026-07-03', rates: { EUR: 0.8, JPY: 40.0 } }.to_json
      )
  end

  before { request_stub }

  it 'updates rates of currencies with rate provider' do
    subject
    expect(eur.reload.rate).to eq 1.25
    expect(jpy.reload.rate).to eq 0.025
    expect(request_stub).to have_been_requested
  end

  it 'does not touch currencies without rate provider' do
    expect { subject }.to_not change { manual_currency.reload.attributes }
  end

  context 'when currency is missing in provider response' do
    let!(:eur) { FactoryBot.create(:currency, name: 'CHF', rate: 2.0, rate_provider_id: Billing::CurrencyRateProvider::FRANKFURTER) }

    it 'updates other currencies and keeps missing one unchanged' do
      subject
      expect(eur.reload.rate).to eq 2.0
      expect(jpy.reload.rate).to eq 0.025
    end
  end

  context 'when provider request fails' do
    let(:request_stub) do
      stub_request(:get, 'https://api.frankfurter.dev/v1/latest?base=USD').to_return(status: 500)
    end

    it 'does not raise and keeps rates unchanged' do
      expect { subject }.to_not raise_error
      expect(eur.reload.rate).to eq 1.0
      expect(jpy.reload.rate).to eq 1.0
    end
  end

  context 'when no currencies have rate provider' do
    let!(:eur) { FactoryBot.create(:currency, name: 'EUR', rate: 1.0, rate_provider_id: nil) }
    let!(:jpy) { FactoryBot.create(:currency, name: 'JPY', rate: 1.0, rate_provider_id: nil) }

    it 'does not request provider' do
      subject
      expect(request_stub).to_not have_been_requested
    end
  end

  context 'with prometheus enabled' do
    before { allow(PrometheusConfig).to receive(:enabled?).and_return(true) }

    it 'emits updates and duration metrics on success' do
      expect(CurrencyRateProcessor).to receive(:collect_updates_metric).with(2, 'Frankfurter')
      expect(CurrencyRateProcessor).to receive(:collect_duration_metric).with(kind_of(Numeric), 'Frankfurter')
      expect(CurrencyRateProcessor).to_not receive(:collect_error_metric)
      subject
    end

    context 'when provider request fails' do
      let(:request_stub) do
        stub_request(:get, 'https://api.frankfurter.dev/v1/latest?base=USD').to_return(status: 500)
      end

      it 'emits error and duration metrics and no updates' do
        expect(CurrencyRateProcessor).to receive(:collect_error_metric).with('Frankfurter')
        expect(CurrencyRateProcessor).to receive(:collect_duration_metric).with(kind_of(Numeric), 'Frankfurter')
        expect(CurrencyRateProcessor).to_not receive(:collect_updates_metric)
        subject
      end
    end

    context 'when a currency is missing in the provider response' do
      let(:request_stub) do
        stub_request(:get, 'https://api.frankfurter.dev/v1/latest?base=USD')
          .to_return(
            status: 200,
            headers: { 'Content-Type' => 'application/json' },
            body: { base: 'USD', date: '2026-07-03', rates: { EUR: 0.8 } }.to_json
          )
      end

      it 'emits an error metric for the missing currency and still records updates and duration' do
        expect(CurrencyRateProcessor).to receive(:collect_error_metric).with('Frankfurter').once
        expect(CurrencyRateProcessor).to receive(:collect_updates_metric).with(1, 'Frankfurter')
        expect(CurrencyRateProcessor).to receive(:collect_duration_metric).with(kind_of(Numeric), 'Frankfurter')
        subject
      end
    end
  end
end
