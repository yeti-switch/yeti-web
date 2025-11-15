# frozen_string_literal: true

RSpec.describe Api::Rest::Customer::V1::AccountsController, type: :request do
  include_context :json_api_customer_v1_helpers, type: :accounts

  before do
    # Accounts not belongs to current customer
    create_list :account, 1
  end

  describe 'GET /api/rest/customer/v1/accounts' do
    subject do
      get json_api_request_path, params: json_api_request_query, headers: json_api_request_headers
    end

    let(:json_api_request_query) { nil }
    let(:records_qty) { 2 }
    let!(:accounts) { create_list :account, records_qty, contractor: customer }

    it_behaves_like :json_api_customer_v1_check_authorization

    it_behaves_like :json_api_check_pagination do
      let(:records_ids) { accounts.map { |r| r.reload.uuid } }
    end

    context 'with dynamic auth' do
      let(:auth_config) { { customer_id: customer.id } }
      let(:api_access) { nil }

      it 'returns records of this customer' do
        subject
        expect(response.status).to eq(200)
        expect(response_json[:data]).to match_array(
          [
            hash_including(id: accounts.first.reload.uuid),
            hash_including(id: accounts.second.reload.uuid)
          ]
        )
      end

      context 'with account_ids' do
        let!(:accounts) { create_list :account, 4, contractor: customer }
        let(:allowed_accounts) { accounts.slice(0, 2) }
        let(:auth_config) { super().merge account_ids: allowed_accounts.map(&:id) }

        it 'returns only Accounts listed in account_ids' do
          subject
          expect(response_json[:data]).to match_array(
            [
              hash_including(id: allowed_accounts.first.reload.uuid),
              hash_including(id: allowed_accounts.second.reload.uuid)
            ]
          )
        end
      end
    end

    context 'account_ids is empty' do
      it 'returns records of this customer' do
        subject
        expect(response.status).to eq(200)
        expect(response_json[:data]).to match_array(
          [
            hash_including(id: accounts.first.reload.uuid),
            hash_including(id: accounts.second.reload.uuid)
          ]
        )
      end
    end

    context 'with account_ids' do
      let!(:accounts) { create_list :account, 4, contractor: customer }
      let(:allowed_accounts) { accounts.slice(0, 2) }

      before do
        api_access.update!(account_ids: allowed_accounts.map(&:id))
      end

      it 'returns only Accounts listed in account_ids' do
        subject
        expect(response_json[:data]).to match_array(
          [
            hash_including(id: allowed_accounts.first.reload.uuid),
            hash_including(id: allowed_accounts.second.reload.uuid)
          ]
        )
      end
    end

    context 'when raises exception' do
      before do
        expect(Api::Rest::Customer::V1::AccountResource).to receive(:records).once
                                                                             .and_raise(StandardError, 'test error')
      end

      include_examples :jsonapi_server_error
      include_examples :captures_error, request: true do
        let(:capture_error_user) do
          {
            id: api_access.id,
            customer_id: api_access.customer_id,
            login: api_access.login,
            class: CustomerV1Auth::AuthContext.name
          }
        end
        let(:capture_error_tags) do
          {
            action_name: 'index',
            controller_name: 'api/rest/customer/v1/accounts',
            request_id: be_present
          }
        end
      end
    end

    context 'with ransack filters' do
      let(:factory) { :account }
      let(:trait) { %i[with_max_balance with_uuid] }
      let(:factory_attrs) { { contractor: customer } }
      let(:pk) { :uuid }

      it_behaves_like :jsonapi_filters_by_string_field, :name
      it_behaves_like :jsonapi_filters_by_number_field, :balance
      it_behaves_like :jsonapi_filters_by_number_field, :min_balance
      it_behaves_like :jsonapi_filters_by_number_field, :max_balance
      it_behaves_like :jsonapi_filters_by_number_field, :balance_low_threshold
      it_behaves_like :jsonapi_filters_by_number_field, :balance_high_threshold
      it_behaves_like :jsonapi_filters_by_number_field, :destination_rate_limit
      it_behaves_like :jsonapi_filters_by_number_field, :max_call_duration
      it_behaves_like :jsonapi_filters_by_number_field, :external_id
      it_behaves_like :jsonapi_filters_by_uuid_field, :uuid
      it_behaves_like :jsonapi_filters_by_number_field, :origination_capacity
      it_behaves_like :jsonapi_filters_by_number_field, :termination_capacity
      it_behaves_like :jsonapi_filters_by_number_field, :total_capacity
    end

    # TODO: context when no entity found fin index-action
  end

  describe 'GET /api/rest/customer/v1/accounts/{id}' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:record_id) { account.reload.uuid }
    let!(:account) { create(:account, contractor: customer) }

    it_behaves_like :json_api_customer_v1_check_authorization

    context 'when record exists' do
      it 'returns record with expected attributes' do
        subject
        expect(response.status).to eq(200)
        expect(response_json[:data]).to match(
          id: account.reload.uuid,
          type: 'accounts',
          links: anything,
          attributes: {
            name: account.name,
            balance: account.balance.to_s,
            'min-balance': account.min_balance.to_s,
            'max-balance': account.max_balance.to_s,
            'destination-rate-limit': account.destination_rate_limit.to_s,
            'origination-capacity': account.origination_capacity,
            'termination-capacity': account.termination_capacity,
            'total-capacity': account.total_capacity
          }
        )
      end
    end

    context 'request account not listed in allowed_ids' do
      let(:allowed_account) { create(:account, contractor: customer) }
      before { api_access.update!(account_ids: [allowed_account.id]) }

      it 'responds with status 404' do
        subject
        expect(response.status).to eq(404)
      end
    end
  end

  describe 'POST /api/rest/customer/v1/accounts' do
    subject do
      post json_api_request_path, params: json_api_request_body.to_json, headers: json_api_request_headers
    end

    let(:json_api_request_body) do
      {
        data: {
          type: 'accounts',
          attributes: json_api_attributes
        }
      }
    end
    let(:json_api_attributes) do
      { name: 'some name' }
    end

    include_examples :raises_exception, ActionController::RoutingError
  end

  describe 'PATCH /api/rest/customer/v1/accounts/{id}' do
    subject do
      patch json_api_request_path, params: json_api_request_body.to_json, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:record_id) { account.reload.uuid }
    let!(:account) { create(:account, contractor: customer) }
    let(:json_api_request_body) do
      {
        data: {
          id: record_id,
          type: 'accounts',
          attributes: json_api_attributes
        }
      }
    end
    let(:json_api_attributes) do
      { name: 'some new name' }
    end

    include_examples :raises_exception, ActionController::RoutingError
  end

  describe 'DELETE /api/rest/customer/v1/accounts/{id}' do
    subject do
      delete json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:record_id) { account.reload.uuid }
    let!(:account) { create(:account, contractor: customer) }

    include_examples :raises_exception, ActionController::RoutingError
  end
end
