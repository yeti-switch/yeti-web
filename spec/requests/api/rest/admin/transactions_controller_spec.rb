# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::TransactionsController, type: :request do
  include_context :json_api_admin_helpers, type: :transactions

  describe 'POST /api/rest/admin/transactions' do
    subject do
      post json_api_request_path, params: json_api_request_body.to_json, headers: json_api_request_headers
    end

    let(:json_api_request_body) do
      {
        data: {
          type: json_api_resource_type,
          attributes: json_api_request_attributes,
          relationships: json_api_request_relationships
        }
      }
    end
    let(:json_api_request_attributes) { { amount: '10.5', description: 'Admin adjustment' } }
    let(:json_api_request_relationships) do
      { account: { data: { type: 'accounts', id: account.id.to_s } } }
    end

    let(:account) { create(:account) }
    let!(:service) { create(:service, account: account, uuid: SecureRandom.uuid) }

    it 'creates transaction without service' do
      expect { subject }.to change { Billing::Transaction.count }.by(1)
      expect(Billing::Transaction.last).to have_attributes(
                                           account_id: account.id,
                                           service_id: nil,
                                           amount: json_api_request_attributes[:amount].to_d,
                                           description: json_api_request_attributes[:description]
                                         )
      expect(response.status).to eq(201)
    end

    context 'with service relationship' do
      let(:json_api_request_relationships) do
        {
          account: { data: { type: 'accounts', id: account.id.to_s } },
          service: { data: { type: 'services', id: service.id.to_s } }
        }
      end

      it 'creates transaction with service' do
        expect { subject }.to change { Billing::Transaction.count }.by(1)
        expect(Billing::Transaction.last).to have_attributes(
                                             account_id: account.id,
                                             service_id: service.id,
                                             amount: json_api_request_attributes[:amount].to_d,
                                             description: json_api_request_attributes[:description]
                                           )
        expect(response.status).to eq(201)
      end
    end
  end
end
