# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::CustomerTokensController, type: :request do
  include_context :json_api_admin_helpers, type: :'customer-tokens'

  describe 'POST /api/rest/admin/customer-tokens' do
    subject do
      post json_api_request_path, params: json_api_request_body.to_json, headers: json_api_request_headers
    end

    let!(:customer) { create(:customer) }
    let!(:accounts) { create_list(:account, 2, contractor: customer) }
    let!(:numberlists) { create_list(:numberlist, 2) }
    let!(:customer_portal_access_profile) { create(:customer_portal_access_profile) }
    let!(:provision_gateway) { create(:gateway) }
    let(:allowed_ips) { ['127.0.0.1', '::1'] }
    let(:accounts_payload) do
      accs = accounts.reverse + [accounts.first]
      accs.map { |acc| { id: acc.id.to_s, type: 'accounts' } }
    end
    let(:numberlists_payload) do
      nbls = numberlists.reverse + [numberlists.first]
      nbls.map { |nbl| { id: nbl.id.to_s, type: 'numberlists' } }
    end
    let(:json_api_request_body) { { data: json_api_request_data } }
    let(:json_api_request_data) do
      {
        type: json_api_resource_type,
        attributes: json_api_request_attributes,
        relationships: json_api_request_relationships
      }
    end
    let(:json_api_request_attributes) do
      {
        'allow-listen-recording': true,
        'allowed-ips': allowed_ips,
        'customer-portal-access-profile-id': customer_portal_access_profile.id
      }
    end
    let(:json_api_request_relationships) do
      {
        customer: { data: { id: customer.id.to_s, type: 'contractors' } },
        accounts: { data: accounts_payload },
        'allow-outgoing-numberlists': { data: numberlists_payload },
        'provision-gateway': { data: { id: provision_gateway.id.to_s, type: 'gateways' } }
      }
    end

    it 'responds with dynamic token' do
      subject

      expect(response.status).to(
        eq(201),
        -> { "expected status to be 201, but got #{response.status}, body:\n#{response.body}" }
      )
      data = response_json[:data]
      expect(data[:id]).to eq(customer.id.to_s)
      expect(data[:attributes]).to match(
                                     'token': be_present,
                                     'expires-at': be_present
                                   )

      auth_context = CustomerV1Auth::Authorizer.authorize! data[:attributes][:token]
      expect(auth_context).to be_a CustomerV1Auth::AuthContext
      expect(auth_context).to have_attributes(
        customer_id: customer.id,
        account_ids: accounts.map(&:id).sort,
        allow_outgoing_numberlists_ids: numberlists.map(&:id).sort,
        allow_listen_recording: true,
        allowed_ips: allowed_ips,
        customer_portal_access_profile_id: customer_portal_access_profile.id,
        provision_gateway_id: provision_gateway.id
      )
    end

    it_behaves_like :json_api_admin_check_authorization, status: 201

    context 'with minimal payload' do
      let(:json_api_request_attributes) { {} }
      let(:json_api_request_relationships) do
        {
          customer: { data: { id: customer.id.to_s, type: 'contractors' } }
        }
      end

      it 'responds with dynamic token' do
        subject

        expect(response.status).to eq(201)
        data = response_json[:data]
        expect(data[:id]).to eq(customer.id.to_s)
        expect(data[:attributes]).to match(
                                       'token': be_present,
                                       'expires-at': be_present
                                     )

        auth_context = CustomerV1Auth::Authorizer.authorize! data[:attributes][:token]
        expect(auth_context).to be_a CustomerV1Auth::AuthContext
        expect(auth_context).to have_attributes(
          customer_id: customer.id,
          account_ids: [],
          allow_outgoing_numberlists_ids: [],
          allow_listen_recording: false,
          allowed_ips: ['0.0.0.0/0', '::/0'],
          customer_portal_access_profile_id: 1,
          provision_gateway_id: nil
        )
      end
    end

    context 'without attributes nor relationship' do
      let(:json_api_request_data) do
        { type: json_api_resource_type }
      end

      include_examples :returns_json_api_errors, status: 422, errors: [
        {
          detail: "customer - can't be blank",
          source: { pointer: '/data/relationships/customer' }
        }
      ]
    end

    context 'with invalid attributes' do
      let(:json_api_request_attributes) do
        {
          'allow-listen-recording': nil,
          'allowed-ips': ['invalid_ip'],
          'customer-portal-access-profile-id': 2_999_999
        }
      end
      let(:json_api_request_relationships) do
        {
          customer: { data: { id: '1999999', type: 'contractors' } },
          accounts: { data: [id: '2999999', type: 'accounts'] },
          'allow-outgoing-numberlists': { data: [id: '3999999', type: 'numberlists'] },
          'provision-gateway': { data: { id: '4999999', type: 'gateways' } }
        }
      end

      include_examples :returns_json_api_errors, status: 422, errors: [
        {
          detail: "customer - can't be blank",
          source: { pointer: '/data/relationships/customer' }
        },
        {
          detail: 'allow-listen-recording - is not included in the list',
          source: { pointer: '/data/attributes/allow-listen-recording' }
        },
        {
          detail: 'allowed-ips - Allowed IP is not valid',
          source: { pointer: '/data/attributes/allowed-ips' }
        },
        {
          detail: "customer-portal-access-profile - can't be blank",
          source: { pointer: '/data/attributes/customer-portal-access-profile' }
        },
        {
          detail: "provision-gateway - can't be blank",
          source: { pointer: '/data/relationships/provision-gateway' }
        }
      ]
    end
  end
end
