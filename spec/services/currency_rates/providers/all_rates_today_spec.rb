# frozen_string_literal: true

RSpec.describe CurrencyRates::Providers::AllRatesToday, '#rates' do
  subject do
    described_class.new.rates(base: base)
  end

  let(:base) { 'USD' }
  let(:currency_rates_config) { { central_bank_code: 'bcb' } }

  let(:request_stub) do
    stub_request(:get, 'https://allratestoday.com/api/open/central-bank/bcb')
      .to_return(response_attrs)
  end
  let(:response_attrs) do
    {
      status: 200,
      headers: { 'Content-Type' => 'application/json' },
      body: { bank: 'bcb', rate_date: '2026-11-06', stale: stale, rates: table }.to_json
    }
  end
  let(:stale) { false }
  let(:table) do
    [
      { base: 'USD', quote: 'BRL', type: 'reference', value: 4.0 },
      { base: 'EUR', quote: 'BRL', type: 'reference', value: 4.4 },
      { base: 'JPY', quote: 'BRL', type: 'reference', value: 2.0 }
    ]
  end

  before do
    allow(YetiConfig).to receive(:currency_rates).and_return(OpenStruct.new(currency_rates_config))
    request_stub
  end

  it 'returns cross rates to base currency including the home currency' do
    expect(subject).to eq(
      'USD' => 1.0,
      'EUR' => 1.1,
      'JPY' => 0.5,
      'BRL' => 0.25
    )
    expect(request_stub).to have_been_requested
  end

  context 'when base is the home currency of the table' do
    let(:base) { 'BRL' }

    it 'returns the quoted values' do
      expect(subject).to eq(
        'USD' => 4.0,
        'EUR' => 4.4,
        'JPY' => 2.0,
        'BRL' => 1.0
      )
    end
  end

  context 'when the table is quoted from the home currency' do
    let(:base) { 'EUR' }
    let(:table) do
      [
        { base: 'EUR', quote: 'USD', type: 'reference', value: 2.0 },
        { base: 'EUR', quote: 'GBP', type: 'reference', value: 0.5 }
      ]
    end

    it 'inverts the rows' do
      expect(subject).to eq(
        'EUR' => 1.0,
        'USD' => 0.5,
        'GBP' => 2.0
      )
    end
  end

  context 'when the table mixes orientations' do
    let(:base) { 'USD' }
    let(:table) do
      [
        { base: 'USD', quote: 'JPY', type: 'reference', value: 100.0 },
        { base: 'USD', quote: 'CAD', type: 'reference', value: 1.25 },
        { base: 'EUR', quote: 'USD', type: 'reference', value: 2.0 }
      ]
    end

    it 'finds the home currency from the pairs' do
      expect(subject).to eq(
        'USD' => 1.0,
        'JPY' => 0.01,
        'CAD' => 0.8,
        'EUR' => 2.0
      )
    end
  end

  context 'when a pair has a mid rate next to buy and sell' do
    let(:table) do
      [
        { base: 'USD', quote: 'BRL', type: 'reference', value: 1.0 },
        { base: 'EUR', quote: 'BRL', type: 'buy', value: 1.0 },
        { base: 'EUR', quote: 'BRL', type: 'middle', value: 2.0 },
        { base: 'EUR', quote: 'BRL', type: 'sell', value: 9.0 }
      ]
    end

    it 'uses the mid rate' do
      expect(subject).to include('EUR' => 2.0)
    end
  end

  context 'when a pair only has buy and sell' do
    let(:table) do
      [
        { base: 'USD', quote: 'BRL', type: 'buy', value: 3.0 },
        { base: 'USD', quote: 'BRL', type: 'sell', value: 5.0 },
        { base: 'EUR', quote: 'BRL', type: 'buy', value: 6.0 },
        { base: 'EUR', quote: 'BRL', type: 'sell', value: 10.0 }
      ]
    end

    it 'uses their mean' do
      expect(subject).to eq(
        'USD' => 1.0,
        'EUR' => 2.0,
        'BRL' => 0.25
      )
    end
  end

  context 'when a pair only has telegraphic transfer buy and sell' do
    let(:base) { 'BRL' }
    let(:table) do
      [
        { base: 'USD', quote: 'BRL', type: 'tt_buy', value: 3.0 },
        { base: 'USD', quote: 'BRL', type: 'tt_sell', value: 5.0 }
      ]
    end

    it 'uses their mean' do
      expect(subject).to eq('BRL' => 1.0, 'USD' => 4.0)
    end
  end

  context 'when a row has an unusable type or value' do
    let(:table) do
      [
        { base: 'USD', quote: 'BRL', type: 'reference', value: 4.0 },
        { base: 'EUR', quote: 'BRL', type: 'reference', value: 4.4 },
        { base: 'CHF', quote: 'BRL', type: 'monthly_average', value: 5.0 },
        { base: 'JPY', quote: 'BRL', type: 'reference', value: 0 }
      ]
    end

    it 'skips that currency' do
      expect(subject.keys).to contain_exactly('USD', 'EUR', 'BRL')
    end
  end

  context 'when central_bank_url is configured' do
    let(:currency_rates_config) { { central_bank_code: 'bcb', central_bank_url: 'https://rates.example.com/' } }
    let(:request_stub) do
      stub_request(:get, 'https://rates.example.com/api/open/central-bank/bcb')
        .to_return(response_attrs)
    end

    it 'requests that host' do
      subject
      expect(request_stub).to have_been_requested
    end
  end

  context 'when central_bank_code is not configured' do
    let(:currency_rates_config) { {} }

    it 'raises provider error without a request' do
      expect { subject }.to raise_error(CurrencyRates::Providers::Base::Error, /central_bank_code/)
      expect(request_stub).not_to have_been_requested
    end
  end

  context 'when currency_rates is not configured at all' do
    before { allow(YetiConfig).to receive(:currency_rates).and_return(nil) }

    it 'raises provider error' do
      expect { subject }.to raise_error(CurrencyRates::Providers::Base::Error, /central_bank_code/)
    end
  end

  context 'when the table is stale' do
    let(:stale) { true }

    it 'raises provider error, keeping the rates in place' do
      expect { subject }.to raise_error(CurrencyRates::Providers::Base::Error, /stale, last published 2026-11-06/)
    end
  end

  context 'when the table is empty' do
    let(:table) { [] }

    it 'raises provider error' do
      expect { subject }.to raise_error(CurrencyRates::Providers::Base::Error, /no usable rates/)
    end
  end

  context 'when base is not in the table' do
    let(:base) { 'UAH' }

    it 'raises provider error' do
      expect { subject }.to raise_error(CurrencyRates::Providers::Base::Error, /has no UAH rate/)
    end
  end

  context 'when API responds with error status' do
    let(:response_attrs) { { status: 404, body: '{"error":"No published table available for this source"}' } }

    it 'raises provider error' do
      expect { subject }.to raise_error(CurrencyRates::Providers::Base::Error, /HTTP 404/)
    end
  end

  context 'when API responds with invalid json' do
    let(:response_attrs) { { status: 200, body: 'not a json' } }

    it 'raises provider error' do
      expect { subject }.to raise_error(CurrencyRates::Providers::Base::Error, /unexpected response/)
    end
  end

  context 'when API responds without rates' do
    let(:response_attrs) { { status: 200, body: '{}' } }

    it 'raises provider error' do
      expect { subject }.to raise_error(CurrencyRates::Providers::Base::Error, /unexpected response/)
    end
  end
end
