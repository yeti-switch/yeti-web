# frozen_string_literal: true

RSpec.shared_examples :json_api_admin_check_authorization do |status: 200|
  let(:when_valid_auth) { nil }

  context 'with invalid auth token' do
    let(:json_api_auth_token) { 'invalid' }

    include_examples :responds_with_status, 401, without_body: true
  end

  context 'without Authorization header' do
    let(:json_api_request_headers) { super().except('Authorization') }

    include_examples :responds_with_status, 401, without_body: true
  end

  context 'with expired auth token' do
    let(:json_api_auth_token) do
      ::Knock::AuthToken.new(payload: { sub: admin_user.id, exp: 1.minute.ago.to_i }).token
    end

    include_examples :responds_with_status, 401, without_body: true
  end

  context 'when admin_user.allowed_ips does not match request.remote_ip' do
    before do
      admin_user.update! allowed_ips: ['10.4.3.2']
    end

    include_examples :responds_with_status, 401, without_body: true
  end

  context 'when admin_user.allowed_ips does not match request.remote_ip' do
    before do
      admin_user.update! allowed_ips: ['127.0.0.1']
      when_valid_auth
    end

    include_examples :responds_with_status, status
  end
end
