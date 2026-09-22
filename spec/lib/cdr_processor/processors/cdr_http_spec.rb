# frozen_string_literal: true

require 'httpx/adapters/webmock'

RSpec.describe CdrProcessor::Processors::CdrHttp do
  subject do
    consumer.perform_events(events)
  end

  let(:logger) { Logger.new(IO::NULL) }
  let(:cdrs) do
    [
      { id: 1, duration: 2 },
      { id: 2, duration: 2 }
    ]
  end
  let(:events) do
    cdrs.each_with_index.map do |cdr, idx|
      double('Event', id: idx + 1, data: cdr)
    end
  end
  let(:consumer) { described_class.new(logger, 'cdr_billing', 'cdr_http', config) }
  let(:method) { 'POST' }
  let(:cdr_fields) { 'all' }
  let(:config) do
    {
      'url' => 'https://external-endpoint/api/cdr',
      'method' => method,
      'cdr_fields' => cdr_fields,
      'headers' => { 'content-type' => 'application/json' }
    }
  end

  before :each do
    stub_request(config['method'].downcase.to_sym, /#{config['url']}/)
  end

  context 'permit all attributes' do
    it 'performs 2 requests' do
      subject
      expect(WebMock).to have_requested(:post, config['url']).times(2)
      expect(WebMock).to have_requested(:post, config['url']).with(
        headers: { 'X-Yeti-Cdr-Batch-Id' => '', 'X-Yeti-Cdr-Event-Id' => '1' },
        body: { id: 1, duration: 2 }
      )
      expect(WebMock).to have_requested(:post, config['url']).with(
        headers: { 'X-Yeti-Cdr-Batch-Id' => '', 'X-Yeti-Cdr-Event-Id' => '2' },
        body: { id: 2, duration: 2 }
      )
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

    it 'performs 2 requests' do
      subject
      expect(WebMock).to have_requested(:post, config['url']).times(2)
      expect(WebMock).to have_requested(:post, config['url']).with(body: { id: 1, duration: 2 })
      expect(WebMock).to have_requested(:post, config['url']).with(body: { id: 1, duration: 3 })
    end

    context 'when all events are filtered out' do
      let(:config) do
        super().merge 'data_filters' => [
          { field: 'id', op: 'eq', value: 2 },
          { field: 'duration', op: 'gt', value: 0 }
        ]
      end
      let(:cdrs) do
        [
          { id: 1, duration: 2 },
          { id: 2, duration: 0 },
          { id: 1, duration: 0 }
        ]
      end

      it 'does not send any requests' do
        subject
        expect(WebMock).not_to have_requested(:post, config['url'])
      end
    end
  end

  context 'with basic auth credentials' do
    let(:config) { super().merge('auth_user' => 'yeti', 'auth_password' => 'secret') }

    it 'sends requests with basic auth header' do
      subject
      expect(WebMock).to have_requested(:post, config['url']).times(2)
                                                             .with(headers: { 'Authorization' => "Basic #{Base64.strict_encode64('yeti:secret')}" })
    end
  end

  context 'permit array attribute' do
    let(:cdr_fields) { ['id'] }

    it 'performs 2 requests' do
      subject
      expect(WebMock).to have_requested(:post, config['url']).times(2)
      expect(WebMock).to have_requested(:post, config['url']).with(body: { id: 1 })
      expect(WebMock).to have_requested(:post, config['url']).with(body: { id: 2 })
    end
  end

  # HTTPX only fails on 4xx/5xx, so without an explicit check a redirect would
  # count as a delivered CDR.
  describe 'response status' do
    context 'when the endpoint answers with a redirect' do
      before do
        stub_request(:post, /#{config['url']}/).to_return(status: 302, headers: { 'Location' => 'https://moved/api/cdr' })
      end

      it 'raises and stops after the first CDR' do
        expect { subject }.to raise_error(
          CdrProcessor::Processors::CdrHttpBase::UnexpectedResponseStatus,
          'unexpected HTTP status 302 (expected 2xx), location: https://moved/api/cdr'
        )
        expect(WebMock).to have_requested(:post, config['url']).once
      end
    end

    context 'when the endpoint answers 204' do
      before { stub_request(:post, /#{config['url']}/).to_return(status: 204) }

      it 'treats it as delivered' do
        subject
        expect(WebMock).to have_requested(:post, config['url']).times(2)
      end
    end
  end

  # Proxy behaviour is covered in spec/lib/httpx_proxy_spec.rb; here we only
  # verify the processor wires its config into HttpxProxy.
  describe 'http proxy config' do
    it 'defaults to no proxy and does not inherit the env proxy' do
      expect(consumer.send(:proxy).inherit_env_proxy?).to be false
    end

    context 'with use_env_proxy enabled' do
      let(:config) { super().merge('use_env_proxy' => true) }

      it 'inherits the env proxy' do
        expect(consumer.send(:proxy).inherit_env_proxy?).to be true
      end
    end

    context 'with an explicit http_proxy' do
      let(:config) { super().merge('http_proxy' => 'http://proxy.local:3128', 'use_env_proxy' => true) }

      it 'uses the configured proxy over the env proxy' do
        expect(consumer.send(:proxy).inherit_env_proxy?).to be false
      end
    end
  end

  describe 'logging' do
    let(:logger) { SemanticLogger::Test::CaptureLogEvents.new(level: :info) }
    let(:cdrs) { [{ id: 1, duration: 2 }] }

    before { consumer.instance_variable_set(:@batch_id, 42) }

    context 'with debug level' do
      let(:logger) { SemanticLogger::Test::CaptureLogEvents.new(level: :debug) }

      it 'forwards HTTPX debug output to the logger' do
        subject
        expect(WebMock).to have_requested(:post, config['url']).once
        expect(logger.events.map(&:level)).to include(:debug)
      end
    end

    it 'tags the request record with ids and http_status and measures it' do
      subject
      record = logger.events.find { |event| event.message == 'HTTP request completed' }
      expect(record.level).to eq(:info)
      expect(record.named_tags).to include(request_id: match(/\A\h{8}-/), event_id: 1, http_status: 200)
      expect(record.duration).to be_a(Float)
    end

    context 'when the endpoint fails' do
      before { stub_request(:post, /#{config['url']}/).to_return(status: 503) }

      it 'logs the error with http_status' do
        expect { subject }.to raise_error(HTTPX::HTTPError)
        record = logger.events.find { |event| event.level == :error }
        expect(record.message).to start_with('HTTP request failed: <HTTPX::HTTPError>')
        expect(record.named_tags).to include(request_id: match(/\A\h{8}-/), event_id: 1, http_status: 503)
        expect(record.duration).to be_a(Float)
      end
    end

    context 'when the request times out' do
      before { stub_request(:post, /#{config['url']}/).to_raise(HTTPX::TimeoutError.new(30, 'Timed out after 30 seconds')) }

      it 'logs the error without http_status' do
        expect { subject }.to raise_error(HTTPX::TimeoutError)
        record = logger.events.find { |event| event.level == :error }
        expect(record.named_tags).to include(request_id: match(/\A\h{8}-/), event_id: 1)
        expect(record.named_tags).not_to have_key(:http_status)
      end
    end
  end

  describe 'persistent connections' do
    let(:client) { consumer.send(:http_client) }

    it 'builds one persistent session per processor with a single reconnect retry', :aggregate_failures do
      expect(client).to be(consumer.send(:http_client))
      expect(client.class.ancestors).to include(HTTPX::Plugins::Persistent::InstanceMethods)
      expect(client.instance_variable_get(:@options)).to have_attributes(persistent: true, max_retries: 1)
    end

    context 'against a keep-alive endpoint' do
      let(:server) { TCPServer.new('127.0.0.1', 0) }
      let(:config) { super().merge('url' => "http://127.0.0.1:#{server.addr[1]}/cdr") }
      let(:accepted) { [] }
      let(:cdrs) { (1..3).map { |id| { id: id, duration: 2 } } }

      # A real connection is the point here, so the WebMock adapter is taken out of the way.
      around do |example|
        WebMock.disable!
        example.run
      ensure
        WebMock.enable!
      end

      # `let` values are resolved here, on the example thread: RSpec memoization is not
      # callable from the acceptor thread.
      let!(:acceptor) do
        listener = server
        connections = accepted
        Thread.new do
          loop do
            conn = listener.accept
            connections << conn
            Thread.new(conn) { |socket| serve_keep_alive(socket) }
          end
        end
      end

      after do
        acceptor.kill
        server.close
      end

      def serve_keep_alive(socket)
        loop do
          head = +''
          head << socket.readline until head.end_with?("\r\n\r\n")
          socket.read(head[/content-length: (\d+)/i, 1].to_i)
          socket.write "HTTP/1.1 200 OK\r\nContent-Length: 2\r\n\r\nok"
        end
      rescue IOError, SystemCallError
        socket.close
      end

      it 'sends every request over the same TCP connection' do
        subject
        expect(accepted.size).to eq(1)
      end
    end
  end

  describe 'http timeouts config' do
    let(:timeouts) { consumer.send(:http_client).instance_variable_get(:@options).timeout }

    it 'uses default timeouts' do
      expect(timeouts).to include(connect_timeout: 20, write_timeout: 30, read_timeout: 30, request_timeout: 60)
    end

    context 'with timeouts in config' do
      let(:config) { super().merge('read_timeout' => 300, 'request_timeout' => '600') }

      it 'overrides configured timeouts and keeps defaults for the rest' do
        expect(timeouts).to include(connect_timeout: 20, write_timeout: 30, read_timeout: 300.0, request_timeout: 600.0)
      end
    end

    context 'with non-numeric timeout' do
      let(:config) { super().merge('read_timeout' => 'never') }

      it 'raises on initialization' do
        expect { consumer }.to raise_error(ArgumentError, /invalid value for Float/)
      end
    end
  end
end
