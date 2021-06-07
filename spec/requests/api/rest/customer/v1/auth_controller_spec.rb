# frozen_string_literal: true

RSpec.describe Api::Rest::Customer::V1::AuthController, type: :request do
  let(:json_request_path) { '/api/rest/customer/v1/auth' }
  let(:json_request_headers) do
    {
      'Accept' => 'application/json',
      'Content-Type' => 'application/json',
      'REMOTE_ADDR' => remote_ip
    }
  end
  let(:json_request_body) { { auth: attributes } }
  let(:remote_ip) { '127.0.0.1' }

  let!(:api_access) { create :api_access, api_access_attrs }
  let(:api_access_attrs) { {} }

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

  describe 'POST /api/rest/customer/v1/auth' do
    subject do
      post json_request_path, params: json_request_body.to_json, headers: json_request_headers
    end

    let(:attributes) { { login: api_access.login, password: api_access.password } }

    context 'when attributes are valid' do
      it 'responds with jwt' do
        subject
        expect(response.status).to eq(201)
        expect(response_json).to match(jwt: a_kind_of(String))
      end
    end

    context 'when password is invalid' do
      let(:attributes) { super().merge password: 'wrong.password' }

      include_examples :responds_with_failed_login
    end

    context 'when customer not exists' do
      let(:attributes) { super().merge login: 'fake.login' }

      include_examples :responds_with_failed_login
    end

    context 'when IP is not allowed' do
      let(:remote_ip) { '127.0.0.2' }

      include_examples :responds_with_failed_login
    end

    context 'Issue#338: 0.0.0.0/0 allows requests from any IP' do
      let(:api_access_attrs) { { allowed_ips: ['0.0.0.0/0'] } }
      let(:remote_ip) { '104.81.225.117' }

      include_examples :responds_with_status, 201
    end

    context 'Issue#338: request from IP not matches the mask' do
      let(:api_access_attrs) { { allowed_ips: ['192.168.0.0/24'] } }
      let(:remote_ip) { '192.169.1.1' }

      include_examples :responds_with_failed_login
    end
  end
end
