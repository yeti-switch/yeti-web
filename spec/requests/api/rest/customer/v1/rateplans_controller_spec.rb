# frozen_string_literal: true

RSpec.describe Api::Rest::Customer::V1::RateplansController, type: :request do
  include_context :json_api_customer_v1_helpers, type: :rateplans
  # RatePlans for the other customer
  before { create_list(:rateplan, 2) }

  describe 'GET /api/rest/customer/v1/rateplans' do
    subject do
      get json_api_request_path, params: json_api_request_query, headers: json_api_request_headers
    end

    let(:json_api_request_query) { nil }

    it_behaves_like :json_api_customer_v1_check_authorization

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

      before { create_list(:rateplan, 2) }

      let(:records_qty) { 2 }
      let!(:customers_auths) { create_list(:customers_auth, records_qty, customer_id: customer.id) }
      let!(:accounts) { create_list :account, records_qty + 2, contractor: customer }
      let(:allowed_accounts) { accounts.slice(0, records_qty) }

      before do
        customers_auths.map.with_index do |customer_auth, index|
          customer_auth.update!(account_id: accounts[index].id)
        end
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

      it_behaves_like :json_api_check_pagination do
        let(:json_api_request_query) { { sort: 'name' } }
        let(:records_ids) { customers_auths.map { |r| r.rateplan.reload }.sort_by(&:name).map(&:uuid) }
      end
    end

    context 'with ransack filters' do
      before do
        create(:customers_auth, customer: customer, rateplan: suitable_record)
        create(:customers_auth, customer: customer, rateplan: other_record)
      end

      let(:factory) { :rateplan }
      let(:trait) { :with_uuid }
      let(:pk) { :uuid }

      it_behaves_like :jsonapi_filters_by_string_field, :name
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

    it_behaves_like :json_api_customer_v1_check_authorization

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

  describe 'POST /api/rest/customer/v1/rateplans' do
    subject do
      post json_api_request_path, params: json_api_request_body.to_json, headers: json_api_request_headers
    end

    let(:json_api_request_body) do
      {
        data: {
          type: 'rateplans',
          attributes: json_api_attributes
        }
      }
    end
    let(:json_api_attributes) do
      { name: 'some new name' }
    end

    include_examples :raises_exception, ActionController::RoutingError
  end

  describe 'PATCH /api/rest/customer/v1/rateplans/{id}' do
    subject do
      patch json_api_request_path, params: json_api_request_body.to_json, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:record_id) { rateplan.uuid }
    let(:rateplan) { customers_auth.rateplan.reload }
    let!(:customers_auth) { create(:customers_auth, customer_id: customer.id) }
    let(:json_api_request_body) do
      {
        data: {
          id: record_id,
          type: 'rateplans',
          attributes: json_api_attributes
        }
      }
    end
    let(:json_api_attributes) do
      { name: 'some new name' }
    end

    include_examples :raises_exception, ActionController::RoutingError
  end

  describe 'DELETE /api/rest/customer/v1/rateplans/{id}' do
    subject do
      delete json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:record_id) { rateplan.uuid }
    let(:rateplan) { customers_auth.rateplan.reload }
    let!(:customers_auth) { create(:customers_auth, customer_id: customer.id) }

    include_examples :raises_exception, ActionController::RoutingError
  end
end
