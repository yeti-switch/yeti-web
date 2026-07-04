# frozen_string_literal: true

RSpec.describe CurrencyRates::Providers::BankOfIsrael, '#rates' do
  subject do
    described_class.new.rates(base: base)
  end

  let(:base) { 'USD' }

  let(:request_stub) do
    stub_request(:get, 'https://boi.org.il/PublicApi/GetExchangeRates')
      .to_return(response_attrs)
  end
  let(:response_attrs) do
    {
      status: 200,
      headers: { 'Content-Type' => 'application/json' },
      body: {
        exchangeRates: [
          { key: 'USD', currentExchangeRate: 4.0, unit: 1, lastUpdate: '2026-07-03T09:21:04Z' },
          { key: 'EUR', currentExchangeRate: 4.4, unit: 1, lastUpdate: '2026-07-03T09:21:04Z' },
          { key: 'JPY', currentExchangeRate: 200.0, unit: 100, lastUpdate: '2026-07-03T09:21:04Z' }
        ]
      }.to_json
    }
  end

  before { request_stub }

  it 'returns cross rates to base currency including ILS' do
    expect(subject).to eq(
      'USD' => 1.0,
      'EUR' => 1.1,
      'JPY' => 0.5,
      'ILS' => 0.25
    )
    expect(request_stub).to have_been_requested
  end

  context 'when base is ILS' do
    let(:base) { 'ILS' }

    it 'returns rates in ILS' do
      expect(subject).to eq(
        'USD' => 4.0,
        'EUR' => 4.4,
        'JPY' => 2.0,
        'ILS' => 1.0
      )
    end
  end

  context 'when base is not quoted by Bank of Israel' do
    let(:base) { 'UAH' }

    it 'raises provider error' do
      expect { subject }.to raise_error(CurrencyRates::Providers::Base::Error, /has no UAH rate/)
    end
  end

  context 'when API responds with error status' do
    let(:response_attrs) { { status: 500, body: 'oops' } }

    it 'raises provider error' do
      expect { subject }.to raise_error(CurrencyRates::Providers::Base::Error, /HTTP 500/)
    end
  end

  context 'when API responds with invalid json' do
    let(:response_attrs) { { status: 200, body: 'not a json' } }

    it 'raises provider error' do
      expect { subject }.to raise_error(CurrencyRates::Providers::Base::Error, /unexpected response/)
    end
  end
end
