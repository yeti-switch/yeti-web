# frozen_string_literal: true

RSpec.describe Api::Rest::Customer::V1::OutgoingNumberlistItemsController, type: :request do
  include_context :json_api_customer_v1_helpers, type: :'outgoing-numberlist-items'

  let!(:nl) { create(:numberlist) }
  let!(:nli) { create(:numberlist_item, numberlist_id: nl.id, key: 'some old key', action_id: 1) }

  let(:api_access_attrs) {
    {
      allow_outgoing_numberlists_ids: [nl.id]
    }
  }

  describe 'GET /api/rest/customer/v1/outgoing-numberlist-items' do
    subject do
      get json_api_request_path, params: json_api_request_query, headers: json_api_request_headers
    end

    let(:json_api_request_query) { nil }

    it_behaves_like :json_api_customer_v1_check_authorization

    context 'account_ids is empty' do
      before do
        create(:customers_auth, customer_id: customer.id, dst_numberlist_id: nl.id)
      end

      it 'returns records of this customer' do
        subject
        expect(response.status).to eq(200)
        expect(response_json[:data]).to match_array(
                                          [
                                            hash_including(id: nli.id.to_s)
                                          ]
                                        )
      end
    end

    context 'with account_ids' do
      let!(:nls) { create_list(:numberlist, 2) }
      let!(:nlis) { create_list(:numberlist_item, 2, numberlist_id: nls.sample.id) }

      let(:api_access_attrs) {
        {
          allow_outgoing_numberlists_ids: nls.map(&:id)
        }
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
                                          nlis.map do |n|
                                            hash_including(id: n.id.to_s, type: 'outgoing-numberlist-items')
                                          end
                                        )
      end
    end

    context 'with ransack filters' do
      let(:api_access_attrs) {
        {
          allow_outgoing_numberlists_ids: [suitable_record.numberlist_id]
        }
      }

      before do
        create(:customers_auth, customer: customer, dst_numberlist: suitable_record.numberlist)
        create(:customers_auth, customer: customer, dst_numberlist: other_record.numberlist)
      end

      let(:factory) { :numberlist_item }
      let(:pk) { :id }

      it_behaves_like :jsonapi_filters_by_string_field, :key
    end
  end

  describe 'GET /api/rest/customer/v1/outgoing-numberlist-items/{id}' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:record_id) { nli.id.to_s }

    let!(:customers_auth) { create(:customers_auth, customer_id: customer.id, dst_numberlist_id: nl.id) }

    it_behaves_like :json_api_customer_v1_check_authorization

    context 'when record exists' do
      it 'returns record with expected attributes' do
        subject
        expect(response_json[:data]).to match(
                                          id: nli.id.to_s,
                                          'type': 'outgoing-numberlist-items',
                                          'links': anything,
                                          'relationships': {
                                            'outgoing-numberlist': {
                                              'links': anything
                                            }
                                          },
                                          'attributes': {
                                            'key': nli.key,
                                            'action-id': nli.action_id
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

  describe 'POST /api/rest/customer/v1/outgoing-numberlist-items' do
    subject do
      post json_api_request_path, params: json_api_request_body.to_json, headers: json_api_request_headers
    end

    let(:json_api_request_body) do
      {
        data: {
          type: 'outgoing-numberlist-items',
          attributes: json_api_attributes,
          relationships: {
            'outgoing-numberlist': {
              "data": {
                "type": 'outgoing-numberlists',
                "id": nl.id.to_s
              }
            }
          }
        }
      }
    end
    let(:json_api_attributes) do
      {
        key: 'some new name',
        'action-id': 2
      }
    end

    context 'with allowed numberlist' do
      let!(:customers_auth) { create(:customers_auth, customer_id: customer.id, dst_numberlist_id: nl.id) }

      it 'returns records of this customer' do
        subject
        expect(response.status).to eq(201)
        expect(response_json[:data]).to match(
                                          id: anything,
                                          'type': 'outgoing-numberlist-items',
                                          'links': anything,
                                          'relationships': {
                                            'outgoing-numberlist': {
                                              'links': anything
                                            }
                                          },
                                          'attributes': {
                                            'key': 'some new name',
                                            'action-id': 2
                                          }
                                        )
        new_nli = Routing::NumberlistItem.find(response_json[:data][:id])
        expect(new_nli.key).to eq('some new name')
        expect(new_nli.action_id).to eq(2)
        expect(new_nli.numberlist_id).to eq(nl.id)
      end
    end

    context 'with not allowed numberlist' do
      it 'returns expection' do
        subject
        expect(response.status).to eq(422)
        expect(response_json[:errors]).to match_array(
                                            [
                                              hash_including(code: '100', status: '422', title: 'Invalid numberlist')
                                            ]
                                          )
        expect { subject }.not_to change { Routing::NumberlistItem.count }
      end
    end
  end

  describe 'PATCH /api/rest/customer/v1/outgoing-numberlist-items/{id}' do
    subject do
      patch json_api_request_path, params: json_api_request_body.to_json, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:record_id) { nli.id.to_s }
    let(:json_api_request_body) do
      {
        data: {
          id: record_id,
          type: 'outgoing-numberlist-items',
          attributes: json_api_attributes
        }
      }
    end
    let(:json_api_attributes) do
      {
        key: 'some new key',
        'action-id': 2
      }
    end

    context 'with allowed numberlist' do
      let!(:customers_auth) { create(:customers_auth, customer_id: customer.id, dst_numberlist_id: nl.id) }

      it 'returns records of this customer' do
        subject
        expect(response.status).to eq(200)
        expect(response_json[:data]).to match(
                                          id: nli.id.to_s,
                                          'type': 'outgoing-numberlist-items',
                                          'links': anything,
                                          'relationships': {
                                            'outgoing-numberlist': {
                                              'links': anything
                                            }
                                          },
                                          'attributes': {
                                            'key': 'some new key',
                                            'action-id': 2
                                          }
                                        )
        expect(nli.reload.key).to eq('some new key')
        expect(nli.reload.action_id).to eq(2)
      end
    end

    context 'with not allowed numberlist' do
      it 'returns records of this customer' do
        subject
        expect(response.status).to eq(404)
        expect(response_json[:errors]).to match_array(
                                            [
                                              hash_including(code: '404', status: '404', title: 'Record not found')
                                            ]
                                          )
        # item should remain same as before
        expect(nli.reload.key).to eq('some old key')
        expect(nli.reload.action_id).to eq(1)
      end
    end
  end

  describe 'DELETE /api/rest/customer/v1/outgoing-numberlist-items/{id}' do
    subject do
      delete json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:record_id) { nli.id.to_s }

    context 'with allowed numberlist' do
      let!(:customers_auth) { create(:customers_auth, customer_id: customer.id, dst_numberlist_id: nl.id) }

      it 'returns records of this customer' do
        subject
        expect(response.status).to eq(204)
        expect(response_json).to be nil

        # object deleted from DB
        expect(Routing::NumberlistItem.exists?(nli.id)).to be(false)
      end
    end

    context 'with not allowed numberlist' do
      it 'returns records of this customer' do
        subject
        expect(response.status).to eq(404)
        expect(response_json[:errors]).to match_array(
                                          [
                                            hash_including(code: '404', status: '404', title: 'Record not found')
                                          ]
                                        )
        # object still exists in db
        expect(Routing::NumberlistItem.exists?(nli.id)).to be(true)
      end
    end
  end
end
