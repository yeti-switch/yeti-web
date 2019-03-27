# frozen_string_literal: true

require 'spec_helper'

describe Api::Rest::Customer::V1::RateplansController, type: :request do
  include_context :json_api_customer_v1_helpers, type: :rateplans
  # RatePlans for the other customer
  before { create_list(:rateplan, 2) }

  describe 'GET /api/rest/customer/v1/rateplans' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    it_behaves_like :json_api_check_authorization

    context 'account_ids is empty' do
      before do
        create(:customers_auth, customer_id: customer.id)
      end

      it 'returns records of this customer' do
        subject
        expect(response.status).to eq(200)
        expect(response_json[:data]).to match_array(
          [
            hash_including(id: customer.rateplans.first.uuid)
          ]
        )
      end
    end

    context 'with account_ids' do
      before do
        create_list(:rateplan, 1)
      end

      let(:rateplans) { create_list(:rateplan, 2) }

      let(:customers_auths) { create_list(:customers_auth, 2, customer_id: customer.id) }

      let(:accounts) { create_list :account, 4, contractor: customer }
      let(:allowed_accounts) { accounts.slice(0, 2) }

      before do
        customers_auths.first.update!(account_id: accounts.first.id)
        customers_auths.second.update!(account_id: accounts.second.id)
        api_access.update!(account_ids: allowed_accounts.map(&:id))
      end

      it 'returns Rateplans connected to allowed_accounts' do
        subject
        expect(response_json[:data]).to match_array(
          [
            hash_including(id: CustomersAuth.find_by(account_id: allowed_accounts.first).rateplan.uuid),
            hash_including(id: CustomersAuth.find_by(account_id: allowed_accounts.second).rateplan.uuid)
          ]
        )
      end
    end
  end

  describe 'GET /api/rest/customer/v1/rateplans/{id}' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:record_id) { rateplan.uuid }
    let(:rateplan) { customers_auth.rateplan.reload }

    let!(:customers_auth) { create(:customers_auth, customer_id: customer.id) }

    it_behaves_like :json_api_check_authorization

    context 'when record exists' do
      it 'returns record with expected attributes' do
        subject
        expect(response_json[:data]).to match(
          id: rateplan.uuid,
          'type': 'rateplans',
          'links': anything,
          'attributes': {
            'name': rateplan.name
          }
        )
      end
    end

    context 'request rateplan not listed in allowed_ids' do
      let!(:allowed_account) { create(:account, contractor: customer) }

      before { api_access.update!(account_ids: [allowed_account.id]) }

      include_examples :responds_with_status, 404
    end
  end
end
