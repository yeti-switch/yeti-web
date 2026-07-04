# frozen_string_literal: true

RSpec.describe CurrencyRates::Providers::Nbu, '#rates' do
  subject do
    described_class.new.rates(base: base)
  end

  let(:base) { 'USD' }

  let(:request_stub) do
    stub_request(:get, 'https://bank.gov.ua/NBUStatService/v1/statdirectory/exchange?json')
      .to_return(response_attrs)
  end
  let(:response_attrs) do
    {
      status: 200,
      headers: { 'Content-Type' => 'application/json' },
      body: [
        { r030: 840, txt: 'Долар США', rate: 40.0, cc: 'USD', exchangedate: '03.07.2026' },
        { r030: 978, txt: 'Євро', rate: 44.0, cc: 'EUR', exchangedate: '03.07.2026' },
        { r030: 392, txt: 'Єна', rate: 0.25, cc: 'JPY', exchangedate: '03.07.2026' }
      ].to_json
    }
  end

  before { request_stub }

  it 'returns cross rates to base currency including UAH' do
    expect(subject).to eq(
      'USD' => 1.0,
      'EUR' => 1.1,
      'JPY' => 0.00625,
      'UAH' => 0.025
    )
    expect(request_stub).to have_been_requested
  end

  context 'when base is UAH' do
    let(:base) { 'UAH' }

    it 'returns rates in UAH' do
      expect(subject).to eq(
        'USD' => 40.0,
        'EUR' => 44.0,
        'JPY' => 0.25,
        'UAH' => 1.0
      )
    end
  end

  context 'when base is not quoted by NBU' do
    let(:base) { 'BTN' }

    it 'raises provider error' do
      expect { subject }.to raise_error(CurrencyRates::Providers::Base::Error, /has no BTN rate/)
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
