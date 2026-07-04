# frozen_string_literal: true

RSpec.describe CurrencyRates::Providers::Frankfurter, '#rates' do
  subject do
    described_class.new.rates(base: 'USD')
  end

  let(:request_stub) do
    stub_request(:get, 'https://api.frankfurter.dev/v1/latest?base=USD')
      .to_return(response_attrs)
  end
  let(:response_attrs) do
    {
      status: 200,
      headers: { 'Content-Type' => 'application/json' },
      body: { base: 'USD', date: '2026-07-03', rates: { EUR: 0.8, UAH: 40.0 } }.to_json
    }
  end

  before { request_stub }

  it 'returns rates inverted to base currency price' do
    expect(subject).to eq('EUR' => 1.25, 'UAH' => 0.025)
    expect(request_stub).to have_been_requested
  end

  describe 'http proxy' do
    let(:http_client_options) { described_class.new.send(:client).instance_variable_get(:@options) }

    context 'when http proxy is configured' do
      before do
        allow(YetiConfig).to receive(:currency_rates).and_return(OpenStruct.new(http_proxy: 'http://proxy.local:3128'))
      end

      it 'builds the http client with the proxy' do
        expect(http_client_options.proxy.uri.to_s).to eq 'http://proxy.local:3128'
      end
    end

    context 'when http proxy is not configured' do
      before do
        allow(YetiConfig).to receive(:currency_rates).and_return(OpenStruct.new(http_proxy: nil))
      end

      it 'builds the http client without a proxy' do
        expect(http_client_options).to_not respond_to(:proxy)
      end
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
