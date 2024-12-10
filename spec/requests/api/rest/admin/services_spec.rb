# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::ServicesController, type: :request, bullet: [:n] do
  include_context :json_api_admin_helpers, type: :services

  shared_examples :responds_with_service_data_single do |status: 200|
    include_examples :returns_json_api_record, status:, relationships: %i[account service-type transactions] do
      let(:json_api_record_id) { record_id }
      let(:json_api_record_attributes) do
        record.reload
        {
          name: record.name,
          variables: record.variables&.deep_symbolize_keys,
          state: record.state,
          'initial-price': record.initial_price.to_s,
          'renew-price': record.renew_price.to_s,
          'created-at': record.created_at.iso8601(3),
          'renew-at': record.renew_at&.iso8601(3),
          'renew-period': record.renew_period,
          uuid: record.uuid
        }
      end
    end
  end

  describe 'GET /api/rest/admin/services' do
    subject do
      get json_api_request_path, params: json_api_request_query, headers: json_api_request_headers
    end

    let(:json_api_request_query) { nil }
    let(:records_qty) { 8 }
    let!(:records) do
      service_types = create_list(:service_type, 3)
      accounts = create_list(:account, 3)
      Array.new(records_qty) { create(:service, type: service_types.sample, account: accounts.sample) }
    end

    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) { records.map { |r| r.id.to_s } }
    end

    it_behaves_like :json_api_admin_check_authorization

    it_behaves_like :json_api_check_pagination do
      let(:records_ids) { records.sort_by(&:id).map { |r| r.id.to_s } }
    end
  end

  describe 'GET /api/rest/admin/services/{id}' do
    subject do
      get json_api_request_path, params: json_api_request_query, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:record_id) { record.id.to_s }
    let(:json_api_request_query) { nil }

    let!(:account) { create(:account) }
    let!(:service_type) { create(:service_type) }
    let!(:record) { create(:service, record_attrs) }
    let(:record_attrs) { { type: service_type, account: } }

    include_examples :responds_with_service_data_single

    it_behaves_like :json_api_admin_check_authorization

    context 'with non-existed id' do
      let(:record_id) { (record.id + 1_000).to_s }

      include_examples :responds_with_status, 404
    end
  end

  describe 'POST /api/rest/admin/services' do
    subject do
      post json_api_request_path, params: json_api_request_body.to_json, headers: json_api_request_headers
    end

    shared_examples :creates_billing_service do
      let(:default_attrs) do
        { name: nil, renew_at: nil, variables: nil, renew_period_id: nil }
      end

      it 'creates billing service' do
        expect { subject }.to change { Billing::Service.count }.by(1)
        new_record = Billing::Service.last!
        expect(new_record).to have_attributes(
          **default_attrs,
          **expected_attrs,
          created_at: be_within(2).of(Time.current)
        )
      end
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
    let(:json_api_request_attributes) do
      {
        'initial-price': '12.34',
        'renew-price': '1.23'
      }
    end
    let(:json_api_request_relationships) do
      {
        account: { data: { id: account.id.to_s, type: 'accounts' } },
        'service-type': { data: { id: service_type.id.to_s, type: 'service-types' } }
      }
    end

    let!(:account) { create(:account) }
    let!(:service_type) { create(:service_type) }

    context 'with only required attributes' do
      include_examples :responds_with_service_data_single, status: 201 do
        let(:record) { Billing::Service.last! }
        let(:record_id) { record.id.to_s }
      end
      include_examples :creates_billing_service do
        let(:expected_attrs) do
          { account:, type: service_type, initial_price: 12.34, renew_price: 1.23 }
        end
      end
    end

    context 'with all attributes changed' do
      let(:json_api_request_attributes) do
        super().merge name: 'some name',
                      'renew-at': 1.day.from_now.change(usec: 0),
                      variables: { 'key': 'value' },
                      'renew-period': 'Month'
      end

      include_examples :responds_with_service_data_single, status: 201 do
        let(:record) { Billing::Service.last! }
        let(:record_id) { record.id.to_s }
      end
      include_examples :creates_billing_service do
        let(:expected_attrs) do
          {
            account:,
            type: service_type,
            initial_price: 12.34,
            renew_price: 1.23,
            name: 'some name',
            renew_at: json_api_request_attributes[:'renew-at'],
            variables: json_api_request_attributes[:variables].deep_stringify_keys,
            renew_period_id: Billing::Service::RENEW_PERIOD_ID_MONTH
          }
        end
      end
    end

    context 'without attributes and relationships' do
      let(:json_api_request_attributes) { {} }
      let(:json_api_request_relationships) { {} }

      include_examples :returns_json_api_errors, status: 422, errors: [
        { detail: 'account - must exist', source: { pointer: '/data/relationships/account' } },
        { detail: 'service-type - must exist', source: { pointer: '/data/relationships/service-type' } },
        { detail: "initial-price - can't be blank", source: { pointer: '/data/attributes/initial-price' } },
        { detail: "renew-price - can't be blank", source: { pointer: '/data/attributes/renew-price' } }
      ]
    end
  end
end
