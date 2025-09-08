# frozen_string_literal: true

RSpec.describe Api::Rest::Customer::V1::RatesController, type: :request do
  include_context :json_api_customer_v1_helpers, type: :rates
  # Rates for the other customer
  before { create_list(:customers_auth, 2) }

  before(:each, :with_rateplan_with_customer) do
    create(:customers_auth, customer_id: customer.id)
  end

  before(:each, :with_rateplans_with_accounts) do
    accounts.each do |account|
      create(:customers_auth, customer_id: customer.id, account_id: account.id)
    end
  end

  describe 'GET /api/rest/customer/v1/rates' do
    subject do
      get json_api_request_path, params: json_api_request_query, headers: json_api_request_headers
    end

    let(:json_api_request_query) { nil }

    it_behaves_like :json_api_customer_v1_check_authorization

    context 'account_ids is empty', :with_rateplan_with_customer do
      before { create_list(:rate, 2) }
      let(:records_qty) { 2 }
      let!(:rates) { create_list(:rate, records_qty, rate_group: create(:rate_group, rateplans: [customer.rateplans.first])) }

      it_behaves_like :json_api_check_pagination do
        # api sorting rates by prefix so we have to sort expected array too.
        let(:records_ids) { rates.sort_by(&:prefix).map { |r| r.reload.uuid } }
      end

      it 'returns records of this customer' do
        subject
        expect(response.status).to eq(200)
        expect(response_json[:data]).to match_array(
          [
            hash_including(id: rates.first.reload.uuid),
            hash_including(id: rates.second.reload.uuid)
          ]
        )
      end
    end

    context 'with account_ids', :with_rateplans_with_accounts do
      let(:accounts) { create_list :account, 4, contractor: customer }
      let(:allowed_accounts) { accounts.slice(0, 2) }

      before do
        api_access.update!(account_ids: allowed_accounts.map(&:id))
      end

      let!(:rates) { create_list(:rate, 2, rate_group: create(:rate_group, rateplans: [Routing::Rateplan.where_account(allowed_accounts.first.id).first])) }

      before do
        create_list(:rate, 2) # other customer
      end

      it 'returns Rates connected to allowed_accounts' do
        subject
        expect(response_json[:data]).to match_array(
          [
            hash_including(id: CustomersAuth.find_by(account_id: allowed_accounts.first).destinations.first.uuid),
            hash_including(id: CustomersAuth.find_by(account_id: allowed_accounts.first).destinations.last.uuid)
          ]
        )
      end
    end

    context 'with ransack filters' do
      before do
        customers_auth = create(:customers_auth, customer: customer)
        customers_auth.rateplan.update! rate_groups: [suitable_record.rate_group, other_record.rate_group]
      end

      let(:factory) { :destination }
      let(:trait) { :with_uuid }
      let(:pk) { :uuid }

      it_behaves_like :jsonapi_filters_by_boolean_field, :enabled
      it_behaves_like :jsonapi_filters_by_string_field, :prefix
      it_behaves_like :jsonapi_filters_by_number_field, :next_rate
      it_behaves_like :jsonapi_filters_by_number_field, :connect_fee
      it_behaves_like :jsonapi_filters_by_number_field, :initial_interval
      it_behaves_like :jsonapi_filters_by_number_field, :next_interval
      it_behaves_like :jsonapi_filters_by_number_field, :initial_rate
      it_behaves_like :jsonapi_filters_by_boolean_field, :reject_calls
      it_behaves_like :jsonapi_filters_by_datetime_field, :valid_from
      it_behaves_like :jsonapi_filters_by_datetime_field, :valid_till
      it_behaves_like :jsonapi_filters_by_uuid_field, :uuid
      it_behaves_like :jsonapi_filters_by_number_field, :dst_number_min_length
      it_behaves_like :jsonapi_filters_by_number_field, :dst_number_max_length
    end
  end

  describe 'GET /api/rest/customer/v1/rates/{id}' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:record_id) { rate.reload.uuid }

    let!(:customers_auth) { create(:customers_auth, customer_id: customer.id) }

    let(:rateplan) { customers_auth.rateplan.reload }

    let!(:rate_group) { create(:rate_group, rateplans: [rateplan]) }
    let!(:rate) { create(:rate, rate_group: rate_group) }

    it_behaves_like :json_api_customer_v1_check_authorization

    context 'when record exists' do
      it 'returns record with expected attributes' do
        subject
        expect(response_json[:data]).to match(
          id: rate.reload.uuid,
          'type': 'rates',
          'links': anything,
          'attributes': {
            'prefix': rate.prefix,
            'dst-number-min-length': rate.dst_number_min_length,
            'dst-number-max-length': rate.dst_number_max_length,
            'enabled': rate.enabled,
            'reject-calls': rate.reject_calls,
            'initial-rate': rate.initial_rate.to_s,
            'initial-interval': rate.initial_interval,
            'next-rate': rate.next_rate.to_s,
            'next-interval': rate.next_interval,
            'connect-fee': rate.connect_fee.to_s,
            'valid-from': rate.valid_from.iso8601(3),
            'valid-till': rate.valid_till.iso8601(3),
            'network-prefix-id': rate.network_prefix_id
          }
        )
      end
    end

    context 'request rate not listed in allowed_ids' do
      let!(:allowed_account) { create(:account, contractor: customer) }

      before { api_access.update!(account_ids: [allowed_account.id]) }

      include_examples :responds_with_status, 404
    end
  end

  describe 'POST /api/rest/customer/v1/rates' do
    subject do
      post json_api_request_path, params: json_api_request_body.to_json, headers: json_api_request_headers
    end

    let(:json_api_request_body) do
      {
        data: {
          type: 'rates',
          attributes: json_api_attributes
        }
      }
    end
    let(:json_api_attributes) do
      { prefix: '123' }
    end

    include_examples :raises_exception, ActionController::RoutingError
  end

  describe 'PATCH /api/rest/customer/v1/rates/{id}' do
    subject do
      patch json_api_request_path, params: json_api_request_body.to_json, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:record_id) { rate.reload.uuid }
    let!(:customers_auth) { create(:customers_auth, customer_id: customer.id) }
    let(:rateplan) { customers_auth.rateplan.reload }
    let!(:rate_group) { create(:rate_group, rateplans: [rateplan]) }
    let!(:rate) { create(:rate, rate_group: rate_group) }
    let(:json_api_request_body) do
      {
        data: {
          id: record_id,
          type: 'rates',
          attributes: json_api_attributes
        }
      }
    end
    let(:json_api_attributes) do
      { prefix: '123' }
    end

    include_examples :raises_exception, ActionController::RoutingError
  end

  describe 'DELETE /api/rest/customer/v1/rates/{id}' do
    subject do
      delete json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:record_id) { rate.reload.uuid }
    let!(:customers_auth) { create(:customers_auth, customer_id: customer.id) }
    let(:rateplan) { customers_auth.rateplan.reload }
    let!(:rate_group) { create(:rate_group, rateplans: [rateplan]) }
    let!(:rate) { create(:rate, rate_group: rate_group) }

    include_examples :raises_exception, ActionController::RoutingError
  end
end
