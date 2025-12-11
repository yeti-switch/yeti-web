# frozen_string_literal: true

RSpec.describe Api::Rest::Customer::V1::CountriesController, type: :request do
  include_context :json_api_customer_v1_helpers, type: :countries

  describe 'GET /api/rest/customer/v1/countries' do
    subject do
      get json_api_request_path, params: json_api_request_query, headers: json_api_request_headers
    end

    let(:json_api_request_query) { nil }

    it_behaves_like :json_api_customer_v1_check_authorization

    it 'returns json api collection of records' do
      subject

      expect(response_json[:errors]).to eq nil
      expect(response_json[:data].pluck(:id).size).to eq 50
      expect(response_json[:data].pluck(:type).uniq).to eq ['countries']
    end

    describe 'filtering' do
      context 'by name' do
        let!(:matching_country) { System::Country.find_by!(name: 'Ukraine') }
        let(:json_api_request_query) { { filter: { name: 'Ukraine' } } }

        it 'returns only Ukraine country' do
          subject

          expect(response_json[:errors]).to eq nil
          expect(response_json[:data].first[:attributes]).to eq(
            {
              name: 'Ukraine',
              iso2: 'UA'
            }
          )
        end
      end
    end
  end

  describe 'GET /api/rest/customer/v1/countries/{id}' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:record) { System::Country.take! }
    let(:record_id) { record.id }

    it_behaves_like :json_api_customer_v1_check_authorization

    include_examples :returns_json_api_record do
      let(:json_api_record_id) { record.id.to_s }
      let(:json_api_record_attributes) { { name: record.name, iso2: record.iso2 } }
    end
  end
end
