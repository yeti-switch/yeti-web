# frozen_string_literal: true

RSpec.describe 'instrumentation_notification.rb', type: :request do
  describe 'creation API Logs' do
    context 'when perform invalid request format' do
      subject { get '/api/rest/invalid_request/1/format' }

      it 'should create Log::ApiLog with properly attributes' do
        expect { subject }.to change(Log::ApiLog, :count).by(1)

        api_log = Log::ApiLog.where(path: '/api/rest/invalid_request/1/format').last!
        expect(api_log).to have_attributes(
          path: '/api/rest/invalid_request/1/format',
          controller: 'ApplicationController',
          action: 'render_404',
          method: 'GET',
          request_body: nil,
          request_headers: nil,
          response_body: nil,
          response_headers: nil,
          status: 404,
          remote_ip: '127.0.0.1',
          request_id: be_present
        )
      end
    end

    context 'when X-Request-Id header is provided' do
      subject { get '/api/rest/invalid_request/1/format', headers: { 'X-Request-Id' => request_id } }

      let(:request_id) { SecureRandom.uuid }

      it 'should save provided request_id' do
        expect { subject }.to change(Log::ApiLog, :count).by(1)

        api_log = Log::ApiLog.where(path: '/api/rest/invalid_request/1/format').last!
        expect(api_log.request_id).to eq(request_id)
      end
    end
  end
end
