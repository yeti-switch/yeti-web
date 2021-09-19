# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::AuthController do
  let(:json_request_path) { '/api/rest/admin/auth' }
  let(:json_request_headers) do
    {
      'Accept' => 'application/json',
      'Content-Type' => 'application/json'
    }
  end
  let(:json_request_body) { { auth: attributes } }

  let!(:admin) { create(:admin_user, admin_attrs) }
  let(:admin_attrs) do
    { username: 'test-admin', password: 'password' }
  end

  describe 'POST create' do
    subject do
      post json_request_path, params: json_request_body.to_json, headers: json_request_headers
    end

    context 'when attributes are valid' do
      let(:attributes) do
        {
          username: admin_attrs[:username],
          password: admin_attrs[:password]
        }
      end

      context 'ldap' do
        before do
          allow(AdminUser).to receive(:ldap_config_exists?) { true }
        end

        it 'responds successfully' do
          subject
          expect(response.status).to eq(201)
          expect(response_json).to match(jwt: a_kind_of(String))
        end

        context 'when admin.allowed_ips does not match request.remote_ip' do
          let(:admin_attrs) do
            super().merge allowed_ips: ['127.0.0.1']
          end

          it 'responds successfully' do
            subject
            expect(response.status).to eq(201)
            expect(response_json).to match(jwt: a_kind_of(String))
          end
        end

        context 'when admin.allowed_ips does not match request.remote_ip' do
          let(:admin_attrs) do
            super().merge allowed_ips: ['10.1.2.3']
          end

          it 'responds with failed login', :aggregate_failures do
            subject
            expect(response.status).to eq(401)
            expect(response_json).to match(
                                       errors: [
                                         title: 'Authentication failed',
                                         detail: 'Your IP address is not allowed.',
                                         code: '401',
                                         status: '401'
                                       ]
                                     )
          end
        end
      end

      context 'no ldap' do
        before do
          allow(AdminUser).to receive(:ldap_config_exists?) { false }
        end

        it 'responds successfully' do
          subject
          expect(response.status).to eq(201)
          expect(response_json).to match(jwt: a_kind_of(String))
        end
      end
    end

    context 'when attributes are invalid' do
      let(:attributes) { { username: 'test-admin', password: 'wrong_password' } }

      it 'responds with failed login', :aggregate_failures do
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
  end
end
