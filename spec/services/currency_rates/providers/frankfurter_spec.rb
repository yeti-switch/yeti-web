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

  # Proxy behaviour itself is covered in spec/lib/httpx_proxy_spec.rb; here we
  # only verify the provider wires its config into HttpxProxy.
  describe 'http proxy' do
    let(:provider) { described_class.new }

    before do
      allow(YetiConfig).to receive(:currency_rates).and_return(OpenStruct.new(currency_rates_config))
    end

    context 'when http proxy is configured' do
      let(:currency_rates_config) { { http_proxy: 'http://proxy.local:3128' } }

      it 'builds the http client with the configured proxy' do
        options = provider.send(:client).instance_variable_get(:@options)
        expect(options.proxy.uri.to_s).to eq 'http://proxy.local:3128'
      end
    end

    context 'when http proxy is not configured and use_env_proxy is disabled' do
      let(:currency_rates_config) { { http_proxy: nil, use_env_proxy: false } }

      it 'does not inherit the env proxy' do
        expect(provider.send(:proxy).inherit_env_proxy?).to be false
      end
    end

    context 'when http proxy is not configured and use_env_proxy is enabled' do
      let(:currency_rates_config) { { http_proxy: nil, use_env_proxy: true } }

      it 'inherits the env proxy' do
        expect(provider.send(:proxy).inherit_env_proxy?).to be true
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
