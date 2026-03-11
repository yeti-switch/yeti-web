# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::CurrenciesController, type: :request do
  include_context :json_api_admin_helpers, type: :currencies

  describe 'GET /api/rest/admin/currencies' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let!(:currencies) do
      FactoryBot.create_list(:currency, 2)
    end

    include_examples :jsonapi_responds_with_pagination_links
    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) do
        currencies.map { |r| r.id.to_s }
      end
    end

    it_behaves_like :json_api_admin_check_authorization
  end

  describe 'GET /api/rest/admin/currencies/{id}' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:record_id) { currency.id.to_s }
    let!(:currency) { FactoryBot.create(:currency) }

    include_examples :returns_json_api_record, relationships: [] do
      let(:json_api_record_id) { record_id }
      let(:json_api_record_attributes) do
        {
          name: currency.name,
          rate: currency.rate
        }
      end
    end

    it_behaves_like :json_api_admin_check_authorization
  end

  describe 'POST /api/rest/admin/currencies' do
    subject do
      post json_api_request_path, params: json_api_request_body.to_json, headers: json_api_request_headers
    end

    let(:json_api_request_body) do
      {
        data: {
          type: json_api_resource_type,
          attributes: json_api_request_attributes
        }
      }
    end
    let(:json_api_request_attributes) do
      { name: 'EUR', rate: 1.2 }
    end

    include_examples :returns_json_api_record, relationships: [], status: 201 do
      let(:json_api_record_id) { Billing::Currency.last!.id.to_s }
      let(:json_api_record_attributes) do
        {
          name: 'EUR',
          rate: 1.2
        }
      end
    end

    include_examples :changes_records_qty_of, Billing::Currency, by: 1

    it_behaves_like :json_api_admin_check_authorization, status: 201

    context 'with invalid name' do
      let(:json_api_request_attributes) { { name: 'INVALID', rate: 1.5 } }

      include_examples :returns_json_api_errors, status: 422, errors: [
        { detail: 'name - is not included in the list', source: { pointer: '/data/attributes/name' } }
      ]
    end

    context 'without attributes' do
      let(:json_api_request_attributes) { {} }

      include_examples :returns_json_api_errors, status: 422, errors: [
        { detail: "name - can't be blank", source: { pointer: '/data/attributes/name' } },
        { detail: "rate - can't be blank", source: { pointer: '/data/attributes/rate' } }
      ]
    end
  end

  describe 'PATCH /api/rest/admin/currencies/{id}' do
    subject do
      patch json_api_request_path, params: json_api_request_body.to_json, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:record_id) { currency.id.to_s }
    let(:json_api_request_body) do
      { data: { id: record_id, type: json_api_resource_type, attributes: json_api_request_attributes } }
    end
    let(:json_api_request_attributes) { { name: 'GBP' } }

    let!(:currency) { FactoryBot.create(:currency) }

    include_examples :returns_json_api_record, relationships: [] do
      let(:json_api_record_id) { currency.id.to_s }
      let(:json_api_record_attributes) do
        hash_including(json_api_request_attributes)
      end
    end

    it_behaves_like :json_api_admin_check_authorization

    context 'when default currency' do
      let!(:currency) { FactoryBot.create(:currency, :default) }

      context 'changing rate' do
        let(:json_api_request_attributes) { { rate: 2.5 } }

        include_examples :returns_json_api_errors, status: 422, errors: [
          { detail: 'rate - must be 1 for default currency', source: { pointer: '/data/attributes/rate' } }
        ]
      end

      context 'changing name' do
        let(:json_api_request_attributes) { { name: 'EUR' } }

        include_examples :returns_json_api_record, relationships: [] do
          let(:json_api_record_id) { currency.id.to_s }
          let(:json_api_record_attributes) do
            hash_including(name: 'EUR')
          end
        end
      end
    end
  end

  describe 'DELETE /api/rest/admin/currencies/{id}' do
    subject do
      delete json_api_request_path, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:record_id) { currency.id.to_s }

    let!(:currency) { FactoryBot.create(:currency) }

    include_examples :responds_with_status, 204
    include_examples :changes_records_qty_of, Billing::Currency, by: -1

    it_behaves_like :json_api_admin_check_authorization, status: 204

    context 'when default currency' do
      let!(:currency) { FactoryBot.create(:currency, :default) }

      include_examples :responds_with_status, 422
    end
  end
end
