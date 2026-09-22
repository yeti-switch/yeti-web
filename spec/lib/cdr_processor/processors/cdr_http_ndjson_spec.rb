# frozen_string_literal: true

require 'httpx/adapters/webmock'

RSpec.describe CdrProcessor::Processors::CdrHttpNdjson do
  subject do
    consumer.perform_group(cdrs)
  end

  let(:logger) { Logger.new(IO::NULL) }
  let(:cdrs) do
    [
      { id: 1, duration: 2, comment: "multi\nline" },
      { id: 2, duration: 2 }
    ]
  end
  let(:consumer) { described_class.new(logger, 'cdr_billing', 'cdr_http_ndjson', config) }
  let(:cdr_fields) { 'all' }
  let(:config) do
    {
      'url' => 'https://external-endpoint/api/cdr',
      'cdr_fields' => cdr_fields
    }
  end

  before :each do
    stub_request :post, /#{config['url']}/
    consumer.instance_variable_set(:@batch_id, 42)
  end

  context 'permit all attributes' do
    it 'sends one CDR per line without envelope' do
      subject
      expect(WebMock).to have_requested(:post, config['url']).once
      expect(WebMock).to have_requested(:post, config['url']).with(
        headers: { 'Content-Type' => 'application/x-ndjson', 'X-Yeti-Cdr-Batch-Id' => '42' },
        body: "{\"id\":1,\"duration\":2,\"comment\":\"multi\\nline\"}\n{\"id\":2,\"duration\":2}"
      )
    end
  end

  context 'permit array attribute' do
    let(:cdr_fields) { ['id'] }

    it 'sends only permitted fields' do
      subject
      expect(WebMock).to have_requested(:post, config['url']).once
                                                             .with(body: "{\"id\":1}\n{\"id\":2}")
    end
  end

  context 'when config has data_filters' do
    let(:config) do
      super().merge 'data_filters' => [
        { field: 'id', op: 'eq', value: 1 },
        { field: 'duration', op: 'gt', value: 0 }
      ]
    end
    let(:cdrs) do
      [
        { id: 1, duration: 2 },
        { id: 1, duration: 3 },
        { id: 2, duration: 2 },
        { id: 1, duration: 0 }
      ]
    end

    it 'sends only matched CDRs' do
      subject
      expect(WebMock).to have_requested(:post, config['url']).once
                                                             .with(body: "{\"id\":1,\"duration\":2}\n{\"id\":1,\"duration\":3}")
    end

    context 'when all events are filtered out' do
      let(:config) { super().merge('data_filters' => [{ field: 'id', op: 'eq', value: 3 }]) }

      it 'does not send any requests' do
        subject
        expect(WebMock).not_to have_requested(:post, config['url'])
      end
    end
  end

  context 'with content_type option' do
    let(:config) { super().merge('content_type' => 'text/plain') }

    it 'sends configured content-type' do
      subject
      expect(WebMock).to have_requested(:post, config['url']).once
                                                             .with(headers: { 'Content-Type' => 'text/plain' })
    end
  end

  context 'with batch_id_header option' do
    let(:config) { super().merge('batch_id_header' => 'X-Batch-Id') }

    it 'sends batch id in configured header only' do
      subject
      expect(WebMock).to have_requested(:post, config['url']).once.with { |req|
        req.headers['X-Batch-Id'] == '42' && !req.headers.key?('X-Yeti-Cdr-Batch-Id')
      }
    end
  end

  context 'with basic auth credentials' do
    let(:config) { super().merge('auth_user' => 'yeti', 'auth_password' => 'secret') }

    it 'sends request with basic auth header' do
      subject
      expect(WebMock).to have_requested(:post, config['url']).once
                                                             .with(headers: { 'Authorization' => "Basic #{Base64.strict_encode64('yeti:secret')}" })
    end
  end

  context 'when the endpoint answers with a redirect' do
    before do
      stub_request(:post, /#{config['url']}/).to_return(status: 301, headers: { 'Location' => 'https://moved/api/cdr' })
    end

    it 'raises instead of treating the batch as delivered' do
      expect { subject }.to raise_error(described_class::UnexpectedResponseStatus, /301/)
    end
  end
end
