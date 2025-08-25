# frozen_string_literal: true

RSpec.describe Api::Rest::Customer::V1::CallAuthController, type: :request do
  include_context :customer_v1_cookie_helpers
  let(:json_request_path) { '/api/rest/customer/v1/call-auth' }

  let(:customer_attrs) { {} }
  let!(:customer) { FactoryBot.create(:customer, customer_attrs) }

  describe 'POST /api/rest/customer/v1/call-auth' do
    subject { post json_request_path, headers: json_request_headers }

    shared_examples :responds_with_failed_login do
      it 'responds with failed login' do
        subject
        expect(response.status).to eq(401)
        expect(response_json).to match(
          errors: [
            title: 'Authorization failed',
            detail: 'Authorization token expired or incorrect.',
            code: '401',
            status: '401'
          ]
        )
      end
    end

    let(:token) do
      result = Authentication::CustomerV1Auth.authenticate!(
        'admin',
        '1234567890',
        remote_ip: '127.0.0.1'
      )

      result.token
    end

    let(:json_request_headers) do
      {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json',
        'REMOTE_ADDR' => remote_ip,
        'Cookie' => "#{Authentication::CustomerV1Auth::COOKIE_NAME}=#{token}"
      }
    end
    let(:remote_ip) { '127.0.0.1' }

    context 'when _yeti_customer_v1_session cookie are valid' do
      let(:provision_gateway_attrs) { { contractor: customer, incoming_auth_allow_jwt: true } }
      let!(:provision_gateway) { FactoryBot.create(:gateway, provision_gateway_attrs) }
      let!(:api_access) { FactoryBot.create(:api_access, api_access_attrs) }
      let(:api_access_attrs) { { login: 'admin', password: '1234567890', customer:, provision_gateway: nil, provision_gateway_id: provision_gateway.id } }
      let(:private_key_path) { YetiConfig&.api&.customer&.call_jwt_private_key }

      it 'responds with jwt', freeze_time: true do
        subject

        expect(response_json[:errors]).to eq nil
        expect(response_json).to match(jwt: a_kind_of(String))
        public_key = OpenSSL::PKey::EC.new(File.read(private_key_path))
        actual_token_payload = JWT.decode(
          response_json[:jwt],
          public_key,
          true,
          algorithm: JwtToken::ES256,
          verify_expiration: true,
          aud: nil,
          verify_aud: nil
        )
        expect(actual_token_payload).to eq(
          [
            {
              'exp' => Authentication::CustomerV1Auth::EXPIRATION_INTERVAL.from_now.to_i,
              'gid' => provision_gateway.uuid,
              'iat' => Time.now.to_i
            },
            {
              'alg' => JwtToken::ES256
            }
          ]
        )
      end
    end

    context 'when _yeti_customer_v1_session cookie are invalid' do
      let(:json_request_headers) do
        {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json',
          'REMOTE_ADDR' => remote_ip,
          'Cookie' => 'invalid'
        }
      end

      it_behaves_like :responds_with_failed_login
    end

    context 'when gateway incoming_auth_allow_jwt=false' do
      let(:provision_gateway_attrs) { { contractor: customer, incoming_auth_allow_jwt: false } }
      let!(:provision_gateway) { FactoryBot.create(:gateway, provision_gateway_attrs) }
      let!(:api_access) { FactoryBot.create(:api_access, api_access_attrs) }
      let(:api_access_attrs) { { login: 'admin', password: '1234567890', customer:, provision_gateway: } }

      it 'should return error message' do
        subject

        expect(response.status).to eq(500)
        expect(response_json).to match(
          errors: [
            title: 'Invalid request',
            detail: 'Incoming JWT is disabled for Provisioning Gateway.',
            code: '500',
            status: '500'
          ]
        )
      end
    end

    context 'when gateway is not found' do
      let!(:api_access) { FactoryBot.create(:api_access, api_access_attrs) }
      let(:api_access_attrs) { { login: 'admin', password: '1234567890', customer:, provision_gateway: nil } }

      it 'should return error message' do
        subject

        expect(response.status).to eq(500)
        expect(response_json).to match(
          errors: [
            title: 'Invalid request',
            detail: 'Provisioning Gateway is not found.',
            code: '500',
            status: '500'
          ]
        )
      end
    end
  end
end
