# frozen_string_literal: true

RSpec.describe Api::Rest::Customer::V1::OutgoingNumberlistsController, type: :request do
  include_context :json_api_customer_v1_helpers, type: :'outgoing-numberlists'

  let!(:nl) { create(:numberlist) }

  let(:api_access_attrs) do
    { customer:, allow_outgoing_numberlists_ids: [nl.id] }
  end

  describe 'GET /api/rest/customer/v1/outgoing-numberlists' do
    subject do
      get json_api_request_path, params: json_api_request_query, headers: json_api_request_headers
    end

    let(:json_api_request_query) { nil }

    it_behaves_like :json_api_customer_v1_check_authorization do
      let(:extra_auth_config) { { allow_outgoing_numberlists_ids: [nl.id] } }
    end

    context 'account_ids is empty' do
      before do
        create(:customers_auth, customer_id: customer.id, dst_numberlist_id: nl.id)
      end

      it 'returns records of this customer' do
        subject
        expect(response.status).to eq(200)
        expect(response_json[:data]).to match_array(
                                          [
                                            hash_including(id: nl.id.to_s)
                                          ]
                                        )
      end
    end

    context 'with account_ids' do
      let!(:nls) { create_list(:numberlist, 2) }

      let(:api_access_attrs) {
        super().merge allow_outgoing_numberlists_ids: nls.map(&:id)
      }

      let(:records_qty) { 2 }
      let!(:accounts) { create_list :account, records_qty + 2, contractor: customer }
      let(:allowed_accounts) { accounts.slice(0, records_qty) }

      before do
        nls.each do |n|
          create(
            :customers_auth,
            customer_id: customer.id,
            account_id: allowed_accounts.sample.id,
            dst_numberlist_id: n.id
          )
        end
      end

      it 'returns Numberlists connected to allowed_accounts' do
        subject
        expect(response_json[:data]).to match_array(
                                          nls.map do |n|
                                            hash_including(id: n.id.to_s, type: 'outgoing-numberlists')
                                          end
                                        )
      end
    end

    context 'with ransack filters' do
      let(:api_access_attrs) {
        super().merge allow_outgoing_numberlists_ids: [suitable_record.id]
      }

      before do
        create(:customers_auth, customer: customer, dst_numberlist: suitable_record)
        create(:customers_auth, customer: customer, dst_numberlist: other_record)
      end

      let(:factory) { :numberlist }
      let(:pk) { :id }

      it_behaves_like :jsonapi_filters_by_string_field, :name
    end

    context 'with dynamic auth' do
      let(:auth_config) { { customer_id: customer.id, allow_outgoing_numberlists_ids: [nl.id] } }
      let(:api_access) { nil }

      before do
        create(:customers_auth, customer_id: customer.id, dst_numberlist_id: nl.id)
      end

      it 'returns records of this customer' do
        subject
        expect(response.status).to eq(200)
        expect(response_json[:data]).to match_array(
                                          [
                                            hash_including(id: nl.id.to_s)
                                          ]
                                        )
      end
    end
  end

  describe 'GET /api/rest/customer/v1/outgoing-numberlists/{id}' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:record_id) { nl.id.to_s }

    let!(:customers_auth) { create(:customers_auth, customer_id: customer.id, dst_numberlist_id: nl.id) }

    it_behaves_like :json_api_customer_v1_check_authorization do
      let(:extra_auth_config) { { allow_outgoing_numberlists_ids: [nl.id] } }
    end

    context 'when record exists' do
      it 'returns record with expected attributes' do
        subject
        expect(response_json[:data]).to match(
                                          id: nl.id.to_s,
                                          'type': 'outgoing-numberlists',
                                          'links': anything,
                                          'attributes': {
                                            'name': nl.name,
                                            'mode-id': nl.mode_id,
                                            'default-action-id': nl.default_action_id
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

  describe 'POST /api/rest/customer/v1/outgoing-numberlists' do
    subject do
      post json_api_request_path, params: json_api_request_body.to_json, headers: json_api_request_headers
    end

    let(:json_api_request_body) do
      {
        data: {
          type: 'outgoing-numberlists',
          attributes: json_api_attributes
        }
      }
    end
    let(:json_api_attributes) do
      { name: 'some new name' }
    end

    include_examples :raises_exception, ActionController::RoutingError
  end

  describe 'PATCH /api/rest/customer/v1/outgoing-numberlists/{id}' do
    subject do
      patch json_api_request_path, params: json_api_request_body.to_json, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:record_id) { nl.id.to_s }
    let!(:customers_auth) { create(:customers_auth, customer_id: customer.id, dst_numberlist_id: nl.id) }
    let(:json_api_request_body) do
      {
        data: {
          id: record_id,
          type: 'outgoing-numberlists',
          attributes: json_api_attributes
        }
      }
    end
    let(:json_api_attributes) do
      { name: 'some new name' }
    end

    include_examples :raises_exception, ActionController::RoutingError
  end

  describe 'DELETE /api/rest/customer/v1/outgoing-numberlists/{id}' do
    subject do
      delete json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:record_id) { nl.id.to_s }
    let!(:customers_auth) { create(:customers_auth, customer_id: customer.id, dst_numberlist_id: nl.id) }

    include_examples :raises_exception, ActionController::RoutingError
  end
end
