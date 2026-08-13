# frozen_string_literal: true

require 'httpx/adapters/webmock'

RSpec.describe CdrProcessor::Processors::CdrHttpBulk do
  subject { consumer.perform_events(events) }

  let(:logger) { Logger.new(IO::NULL) }
  let(:url) { 'https://external-endpoint/api/cdr' }
  let(:batch_id) { 42 }
  let(:bulk_size) { 2 }
  let(:hmac_secret) { nil }
  let(:cdr_fields) { 'all' }
  let(:config) do
    {
      'url' => url,
      'bulk_size' => bulk_size,
      'hmac_secret' => hmac_secret,
      'cdr_fields' => cdr_fields
    }
  end
  let(:consumer) { described_class.new(logger, 'cdr_billing', 'cdr_http_bulk', config) }
  let(:events) { (1..4).map { |id| build_event(id) } }

  # Every request and every acknowledgement in the order they happened, so that
  # bulk composition, ordering and ack payloads can be asserted at once.
  let(:call_log) { [] }
  # 1-based index of the request => HTTP status to respond with.
  let(:response_status_for) { ->(_index) { 200 } }

  def build_event(id, type: 'cdr_full', data: nil)
    data ||= { id: id, duration: id }
    CdrProcessor::Event.new(consumer, 'ev_id' => id, 'ev_type' => type, 'ev_data' => data.to_json)
  end

  def requests
    call_log.filter_map { |kind, payload| payload if kind == :post }
  end

  def request_body(request)
    JSON.parse(request.body)
  end

  def cdr_ids(request)
    request_body(request)['data'].map { |event| event['payload']['id'] }
  end

  def request_header(request, name)
    request.headers.find { |key, _| key.casecmp(name).zero? }&.last
  end

  # [[:post, [cdr ids]], [:ack, [event ids]], ...]
  def flow
    call_log.map do |kind, payload|
      kind == :post ? [:post, cdr_ids(payload)] : [:ack, payload]
    end
  end

  before do
    consumer.instance_variable_set(:@batch_id, batch_id)
    allow(CdrProcessor::CdrDb).to receive(:pgq_events_done!) { |_consumer, _batch_id, ids| call_log << [:ack, ids] }
    stub_request(:post, url).to_return do |request|
      call_log << [:post, request]
      { status: response_status_for.call(requests.size), body: 'ok' }
    end
  end

  describe 'splitting events into bulks' do
    context 'when the event count is a multiple of bulk_size' do
      it 'sends one request per bulk and acks each bulk right after it' do
        subject
        expect(flow).to eq(
          [
            [:post, [1, 2]], [:ack, [1, 2]],
            [:post, [3, 4]], [:ack, [3, 4]]
          ]
        )
      end
    end

    context 'when the last bulk is incomplete' do
      let(:bulk_size) { 3 }
      let(:events) { (1..7).map { |id| build_event(id) } }

      it 'sends the remaining events in a smaller bulk' do
        subject
        expect(flow).to eq(
          [
            [:post, [1, 2, 3]], [:ack, [1, 2, 3]],
            [:post, [4, 5, 6]], [:ack, [4, 5, 6]],
            [:post, [7]], [:ack, [7]]
          ]
        )
      end
    end

    context 'when there are fewer events than bulk_size' do
      let(:bulk_size) { 10 }
      let(:events) { (1..3).map { |id| build_event(id) } }

      it 'sends a single request' do
        subject
        expect(flow).to eq([[:post, [1, 2, 3]], [:ack, [1, 2, 3]]])
      end
    end

    context 'when bulk_size is not configured' do
      let(:bulk_size) { nil }

      it 'sends the whole batch in a single request' do
        subject
        expect(flow).to eq([[:post, [1, 2, 3, 4]], [:ack, [1, 2, 3, 4]]])
      end
    end

    context 'when there are no events' do
      let(:events) { [] }

      it 'does not send anything and does not ack' do
        subject
        expect(call_log).to be_empty
      end
    end
  end

  describe 'request body' do
    let(:events) { [build_event(1), build_event(2)] }

    it 'wraps every event into a type/payload envelope' do
      subject
      expect(request_body(requests.first)).to eq(
        'event_bulk_id' => Digest::MD5.hexdigest('42-1-2'),
        'batch_id' => batch_id,
        'data' => [
          { 'type' => 'cdr_full', 'payload' => { 'id' => 1, 'duration' => 1 } },
          { 'type' => 'cdr_full', 'payload' => { 'id' => 2, 'duration' => 2 } }
        ]
      )
    end

    it 'sends the batch id header' do
      subject
      expect(request_header(requests.first, 'X-Yeti-Cdr-Batch-Id')).to eq('42')
    end

    context 'when the queue carries several event types' do
      let(:events) { [build_event(1), build_event(2, type: 'cdr')] }

      it 'takes the type of every event from the pgq event type' do
        subject
        expect(request_body(requests.first)['data'].map { |event| event['type'] }).to eq(%w[cdr_full cdr])
      end
    end

    context 'when cdr_fields lists the fields to send' do
      let(:cdr_fields) { ['id'] }

      it 'keeps only the listed fields in the payload' do
        subject
        expect(request_body(requests.first)['data']).to eq(
          [
            { 'type' => 'cdr_full', 'payload' => { 'id' => 1 } },
            { 'type' => 'cdr_full', 'payload' => { 'id' => 2 } }
          ]
        )
      end
    end
  end

  describe 'event_bulk_id' do
    it 'differs per bulk' do
      subject
      expect(requests.map { |request| request_body(request)['event_bulk_id'] }.uniq.size).to eq(2)
    end

    it 'stays the same when the same bulk is sent again' do
      subject
      first_ids = requests.map { |request| request_body(request)['event_bulk_id'] }
      call_log.clear
      consumer.perform_events(events)
      expect(requests.map { |request| request_body(request)['event_bulk_id'] }).to eq(first_ids)
    end
  end

  describe 'HMAC signature' do
    context 'when hmac_secret is configured' do
      let(:hmac_secret) { SecureRandom.hex(64) }

      it 'signs every request with the exact body it sends' do
        subject
        expect(requests.size).to eq(2)
        requests.each do |request|
          expect(request_header(request, described_class::HMAC_SIGNATURE_HEADER)).to eq(
            OpenSSL::HMAC.hexdigest(described_class::HMAC_ALGO, hmac_secret, request.body)
          )
        end
      end

      it 'signs each bulk separately' do
        subject
        signatures = requests.map { |request| request_header(request, described_class::HMAC_SIGNATURE_HEADER) }
        expect(signatures.uniq.size).to eq(2)
      end
    end

    context 'when hmac_secret is not a string' do
      let(:hmac_secret) { 1234 }

      it 'signs with its string representation' do
        subject
        expect(request_header(requests.first, described_class::HMAC_SIGNATURE_HEADER)).to eq(
          OpenSSL::HMAC.hexdigest(described_class::HMAC_ALGO, '1234', requests.first.body)
        )
      end
    end

    context 'when hmac_secret is empty' do
      let(:hmac_secret) { '' }

      it 'does not send the signature header' do
        subject
        expect(request_header(requests.first, described_class::HMAC_SIGNATURE_HEADER)).to be_nil
      end
    end

    context 'when hmac_secret is not configured' do
      it 'does not send the signature header' do
        subject
        expect(request_header(requests.first, described_class::HMAC_SIGNATURE_HEADER)).to be_nil
      end
    end
  end

  describe 'when a request fails' do
    let(:events) { (1..6).map { |id| build_event(id) } }
    let(:response_status_for) { ->(index) { index == 2 ? 500 : 200 } }

    it 'raises, acks only the delivered bulks and stops sending' do
      expect { subject }.to raise_error(HTTPX::HTTPError)
      expect(flow).to eq([[:post, [1, 2]], [:ack, [1, 2]], [:post, [3, 4]]])
    end
  end

  # HTTPX only fails on 4xx/5xx, so without an explicit check a redirect would
  # ack the bulk although the endpoint never received it.
  describe 'when the endpoint answers with a redirect' do
    let(:events) { (1..6).map { |id| build_event(id) } }
    let(:response_status_for) { ->(index) { index == 2 ? 302 : 200 } }

    it 'raises and does not ack the redirected bulk' do
      expect { subject }.to raise_error(described_class::UnexpectedResponseStatus)
      expect(flow).to eq([[:post, [1, 2]], [:ack, [1, 2]], [:post, [3, 4]]])
    end
  end

  describe 'data_filters' do
    let(:events) { (1..6).map { |id| build_event(id) } }
    let(:config) do
      super().merge 'data_filters' => [{ field: 'duration', op: 'gt', value: 2 }]
    end

    it 'builds bulks out of the matching events only' do
      subject
      expect(flow).to eq([[:post, [3, 4]], [:ack, [3, 4]], [:post, [5, 6]], [:ack, [5, 6]]])
    end

    context 'when all events are filtered out' do
      let(:config) do
        super().merge 'data_filters' => [{ field: 'duration', op: 'gt', value: 100 }]
      end

      it 'does not send anything and does not ack' do
        subject
        expect(call_log).to be_empty
      end
    end
  end

  describe 'inherited HTTP options' do
    context 'with basic auth credentials' do
      let(:config) { super().merge('auth_user' => 'yeti', 'auth_password' => 'secret') }

      it 'sends the authorization header' do
        subject
        expect(request_header(requests.first, 'Authorization')).to eq("Basic #{Base64.strict_encode64('yeti:secret')}")
      end
    end

    context 'with custom headers' do
      let(:config) { super().merge('headers' => { 'X-Api-Key' => 'secret-key' }) }

      it 'sends them along with the built-in ones' do
        subject
        expect(request_header(requests.first, 'X-Api-Key')).to eq('secret-key')
        expect(request_header(requests.first, 'X-Request-Id')).to be_present
      end
    end

    it 'sends json content type' do
      subject
      expect(request_header(requests.first, 'Content-Type')).to eq('application/json')
    end
  end

  it 'refuses to send events one by one' do
    expect { consumer.perform_group(events) }.to raise_error(NotImplementedError)
  end

  it 'measures the time spent sending the batch' do
    subject
    expect(consumer.last_perform_group_duration_ms).to be_positive
  end
end
