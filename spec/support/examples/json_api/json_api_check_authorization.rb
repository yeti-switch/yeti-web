# frozen_string_literal: true

RSpec.shared_examples :json_api_check_authorization do
  context 'with invalid auth token' do
    let(:json_api_auth_token) { 'invalid' }

    include_examples :responds_with_status, 401
  end

  context 'without Authorization header' do
    let(:json_api_request_headers) { super().except('Authorization') }

    include_examples :responds_with_status, 401
  end

  context 'with expired auth token' do
    let(:json_api_auth_token) do
      ::Knock::AuthToken.new(payload: { sub: api_access.id, exp: 1.minute.ago.to_i }).token
    end

    include_examples :responds_with_status, 401
  end
end
