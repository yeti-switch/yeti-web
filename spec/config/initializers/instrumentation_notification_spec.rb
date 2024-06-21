# frozen_string_literal: true

RSpec.describe 'instrumentation_notification.rb', type: :request do
  describe 'creation API Logs' do
    context 'when perform invalid request format' do
      subject { get '/api/rest/invalid_request/1/format' }

      it 'should create Log::ApiLog with properly attributes' do
        expect { subject }.to change(Log::ApiLog, :count).by(1)

        expect(Log::ApiLog.last!).to have_attributes(
          path: '/api/rest/invalid_request/1/format',
          controller: 'ApplicationController',
          action: 'render_404',
          method: 'GET',
          request_body: nil,
          request_headers: nil,
          response_body: nil,
          response_headers: nil,
          status: 404,
          remote_ip: nil
        )
      end
    end
  end
end
