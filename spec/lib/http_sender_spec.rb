# frozen_string_literal: true

RSpec.describe HttpSender do
  describe '#send_request' do
    subject do
      described_class.new(url: url, content_type: content_type, body: body).send_request
    end

    let(:url) { 'https://example.com/callback' }
    let(:content_type) { HttpSender::CONTENT_TYPE_JSON }
    let(:body) { '{"foo":"bar"}' }
    let!(:request_stub) do
      WebMock.stub_request(:post, url)
             .with(headers: { 'Content-Type' => content_type }, body: body)
             .and_return(status: response_status, body: response_body)
    end

    context 'when server responds with 200' do
      let(:response_status) { 200 }
      let(:response_body) { '{"success": true}' }

      it 'performs successfully' do
        subject
        expect(request_stub).to have_been_requested
      end
    end

    context 'when server responds with 201' do
      let(:response_status) { 201 }
      let(:response_body) { 'ok' }

      it 'performs successfully' do
        subject
        expect(request_stub).to have_been_requested
      end
    end

    context 'when server responds with 204' do
      let(:response_status) { 204 }
      let(:response_body) { nil }

      it 'performs successfully' do
        subject
        expect(request_stub).to have_been_requested
      end
    end

    context 'when server responds with 500' do
      let(:response_status) { 500 }
      let(:response_body) { 'some_server_error' }

      it 'failed' do
        expect { subject }.to raise_error(HttpSender::Error)
        expect(request_stub).to have_been_requested
      end
    end

    context 'when connection timed out' do
      let(:request_stub) { nil }

      before do
        expect(HTTParty).to receive(:post).once.and_raise(Net::OpenTimeout)
      end

      it 'failed' do
        expect { subject }.to raise_error(HttpSender::TimeoutError)
      end
    end

    context 'when request timed out' do
      let(:request_stub) { nil }

      before do
        expect(HTTParty).to receive(:post).once.and_raise(Net::WriteTimeout)
      end

      it 'failed' do
        expect { subject }.to raise_error(HttpSender::TimeoutError)
      end
    end

    context 'when response timed out' do
      let(:request_stub) { nil }

      before do
        expect(HTTParty).to receive(:post).once.and_raise(Net::ReadTimeout)
      end

      it 'failed' do
        expect { subject }.to raise_error(HttpSender::TimeoutError)
      end
    end
  end
end
