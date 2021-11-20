# frozen_string_literal: true

RSpec.describe Api::Rest::Customer::V1::AuthController, type: :request do
  include_context :customer_v1_cookie_helpers
  let(:json_request_path) { '/api/rest/customer/v1/auth' }

  let!(:api_access) { create :api_access, api_access_attrs }
  let(:api_access_attrs) { {} }

  describe 'POST /api/rest/customer/v1/auth' do
    subject do
      post json_request_path, params: json_request_body.to_json, headers: json_request_headers
    end

    shared_examples :responds_with_failed_login do
      it 'responds with failed login' do
        subject
        expect(response.status).to eq(401)
        expect(response_json).to match(
                                   errors: [
                                     title: 'Authentication failed',
                                     detail: 'Incorrect login or password.',
                                     code: '401',
                                     status: '401'
                                   ]
                                 )
      end
    end

    let(:json_request_headers) do
      {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json',
        'REMOTE_ADDR' => remote_ip
      }
    end
    let(:json_request_body) { { auth: attributes } }
    let(:remote_ip) { '127.0.0.1' }
    let(:attributes) { { login: api_access.login, password: api_access.password } }

    context 'when attributes are valid' do
      it 'responds with jwt', freeze_time: true do
        subject
        expect(response.status).to eq(201)
        expect(response_json).to match(jwt: a_kind_of(String))
        actual_token_payload = JwtToken.decode(
          response_json[:jwt],
          verify_expiration: true,
          aud: [Authentication::CustomerV1Auth::AUDIENCE]
        )
        expect(actual_token_payload).to match(
                                          sub: api_access.id,
                                          aud: [Authentication::CustomerV1Auth::AUDIENCE],
                                          exp: Authentication::CustomerV1Auth::EXPIRATION_INTERVAL.from_now.to_i
                                        )
      end

      context 'when expiration interval is blank' do
        before do
          stub_const('Authentication::CustomerV1Auth::EXPIRATION_INTERVAL', nil)
        end

        it 'responds with jwt' do
          subject
          expect(response.status).to eq(201)
          expect(response_json).to match(jwt: a_kind_of(String))
          actual_token_payload = JwtToken.decode(
            response_json[:jwt],
            verify_expiration: false,
            aud: [Authentication::CustomerV1Auth::AUDIENCE]
          )
          expect(actual_token_payload).to match(
                                            sub: api_access.id,
                                            aud: [Authentication::CustomerV1Auth::AUDIENCE]
                                          )
        end
      end

      context 'with cookie_auth=true' do
        let(:attributes) do
          super().merge cookie_auth: 'true'
        end

        it 'responds with cookie', freeze_time: true do
          subject
          expect(response.status).to eq(201)
          expect(response.body).to be_blank
          expiration = Authentication::CustomerV1Auth::EXPIRATION_INTERVAL.from_now
          expected_cookie = build_customer_cookie(api_access.id, expiration: expiration)
          expect(response.headers['set-cookie']).to eq(expected_cookie)
        end

        context 'when expiration interval is blank' do
          before do
            stub_const('Authentication::CustomerV1Auth::EXPIRATION_INTERVAL', nil)
          end

          it 'responds with cookie', freeze_time: true do
            subject
            expect(response.status).to eq(201)
            expect(response.body).to be_blank
            expected_cookie = build_customer_cookie(api_access.id, expiration: nil)
            expect(response.headers['set-cookie']).to eq(expected_cookie)
          end
        end
      end
    end

    context 'when password is invalid' do
      let(:attributes) { super().merge password: 'wrong.password' }

      include_examples :responds_with_failed_login

      context 'with cookie_auth=true' do
        let(:attributes) do
          super().merge cookie_auth: 'true'
        end

        include_examples :responds_with_failed_login
      end
    end

    context 'when customer not exists' do
      let(:attributes) { super().merge login: 'fake.login' }

      include_examples :responds_with_failed_login

      context 'with cookie_auth=true' do
        let(:attributes) do
          super().merge cookie_auth: 'true'
        end

        include_examples :responds_with_failed_login
      end
    end

    context 'when IP is not allowed' do
      let(:remote_ip) { '127.0.0.2' }

      include_examples :responds_with_failed_login

      context 'with cookie_auth=true' do
        let(:attributes) do
          super().merge cookie_auth: 'true'
        end

        include_examples :responds_with_failed_login
      end
    end

    context 'Issue#338: 0.0.0.0/0 allows requests from any IP' do
      let(:api_access_attrs) { { allowed_ips: ['0.0.0.0/0'] } }
      let(:remote_ip) { '104.81.225.117' }

      include_examples :responds_with_status, 201

      context 'with cookie_auth=true' do
        let(:attributes) do
          super().merge cookie_auth: 'true'
        end

        include_examples :responds_with_status, 201
      end
    end

    context 'Issue#338: request from IP not matches the mask' do
      let(:api_access_attrs) { { allowed_ips: ['192.168.0.0/24'] } }
      let(:remote_ip) { '192.169.1.1' }

      include_examples :responds_with_failed_login

      context 'with cookie_auth=true' do
        let(:attributes) do
          super().merge cookie_auth: 'true'
        end

        include_examples :responds_with_failed_login
      end
    end
  end

  describe 'GET /api/rest/customer/v1/auth' do
    subject do
      get json_request_path, params: nil, headers: json_api_request_headers
    end

    let(:json_api_request_headers) do
      {
        'Accept' => 'application/json',
        'Authorization' => "Bearer #{json_api_auth_token}"
      }
    end
    let(:json_api_auth_token) do
      build_customer_token(api_access.id, expiration: 1.minute.from_now)
    end

    it 'responds with 200' do
      subject
      expect(response.status).to eq 200
      expect(response.body).to be_blank
    end

    it_behaves_like :json_api_customer_v1_check_authorization
  end

  describe 'DELETE /api/customer/v1/auth' do
    subject do
      delete json_request_path, params: nil, headers: json_api_request_headers
    end

    let(:json_api_request_headers) do
      {}
    end

    shared_examples :responds_with_logout_cookie do
      it 'responds with logout cookie' do
        subject
        expect(response.status).to eq(204)
        expiration = Time.parse('1970-01-01 00:00:00 UTC')
        expected_cookie = build_raw_cookie('logout', expiration: expiration)
        expect(response.headers['set-cookie']).to eq(expected_cookie)
      end
    end

    context 'without Authorization nor Cookie header' do
      include_examples :responds_with_logout_cookie
    end

    context 'with valid Authorization header' do
      let(:json_api_request_headers) do
        super().merge('Authorization' => json_api_auth_token)
      end
      let(:json_api_auth_token) do
        build_customer_token(api_access.id, expiration: 1.minute.from_now)
      end

      include_examples :responds_with_logout_cookie
    end

    context 'with valid Cookie header' do
      let(:json_api_request_headers) do
        super().merge('Cookie' => json_api_auth_cookie)
      end
      let(:json_api_auth_cookie) do
        build_customer_cookie(api_access.id, expiration: 1.minute.from_now)
      end

      include_examples :responds_with_logout_cookie
    end
  end
end
