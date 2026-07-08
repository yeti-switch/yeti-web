# frozen_string_literal: true

require 'httpx/adapters/webmock'

RSpec.describe YetiPdf::Client do
  # invoice.pdf_api.base_url comes from config/yeti_web.yml (127.0.0.1:9080).
  let(:base_url) { YetiConfig.invoice.pdf_api.base_url }
  let(:render_url) { "#{base_url}/v1/render" }
  let(:html_url) { "#{base_url}/v1/render/html" }
  let(:template) { '<p>{{ invoice.reference }}</p>' }
  let(:data) { { invoice: { reference: 'INV-1' } } }

  describe '.configured?' do
    it 'is true when base_url is set' do
      expect(described_class.configured?).to be(true)
    end
  end

  describe '.render_pdf' do
    subject { described_class.render_pdf(template: template, data: data) }

    it 'posts the template and data and returns the pdf bytes' do
      stub = stub_request(:post, render_url)
             .to_return(status: 200, headers: { 'Content-Type' => 'application/pdf' }, body: '%PDF-bytes')

      expect(subject).to eq('%PDF-bytes')
      expect(stub).to have_been_requested
      expect(WebMock).to have_requested(:post, render_url)
        .with(headers: { 'Content-Type' => %r{application/json} },
              body: hash_including('template' => template, 'options' => {}))
    end

    it 'raises Error with the status on a non-2xx response' do
      stub_request(:post, render_url).to_return(status: 422, body: '{"error":"template_error"}')

      expect { subject }.to raise_error(YetiPdf::Client::Error, /HTTP 422/)
    end

    it 'raises Error on a transport timeout' do
      stub_request(:post, render_url).to_timeout

      expect { subject }.to raise_error(YetiPdf::Client::Error)
    end
  end

  describe '.render_html' do
    it 'posts to the html endpoint and returns the merged html' do
      stub_request(:post, html_url).to_return(status: 200, body: '<p>INV-1</p>')

      expect(described_class.render_html(template: template, data: data)).to eq('<p>INV-1</p>')
    end
  end

  context 'when pdf_api is not configured' do
    before { allow(YetiConfig).to receive(:invoice).and_return(nil) }

    it 'raises a clear Error' do
      expect { described_class.render_pdf(template: template, data: data) }
        .to raise_error(YetiPdf::Client::Error, /not configured/)
    end
  end

  # Proxy behaviour is covered in spec/lib/httpx_proxy_spec.rb; here we only
  # verify the client wires invoice.pdf_api config into HttpxProxy.
  describe '#proxy_for' do
    let(:cfg) { OpenStruct.new(pdf_api_config) }

    subject(:proxy) { described_class.new.send(:proxy_for, cfg) }

    context 'with defaults' do
      let(:pdf_api_config) { { base_url: base_url } }

      it 'does not inherit the env proxy' do
        expect(proxy.inherit_env_proxy?).to be false
      end
    end

    context 'with use_env_proxy enabled' do
      let(:pdf_api_config) { { base_url: base_url, use_env_proxy: true } }

      it 'inherits the env proxy' do
        expect(proxy.inherit_env_proxy?).to be true
      end
    end

    context 'with an explicit http_proxy' do
      let(:pdf_api_config) { { base_url: base_url, http_proxy: 'http://proxy.local:3128', use_env_proxy: true } }

      it 'uses the configured proxy over the env proxy' do
        expect(proxy.inherit_env_proxy?).to be false
      end
    end
  end
end
