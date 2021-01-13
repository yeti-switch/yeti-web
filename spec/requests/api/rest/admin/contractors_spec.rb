# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::ContractorsController, type: :request do
  include_context :json_api_admin_helpers, type: :contractors

  describe 'GET /api/rest/admin/contractor' do
    subject do
      get json_api_request_path, params: request_params, headers: json_api_request_headers
    end

    let!(:contractors) do
      FactoryBot.create_list(:vendor, 2) # only Contact with contractor
    end
    let(:request_params) { nil }

    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) do
        contractors.map { |r| r.id.to_s }
      end
    end

    context 'with filter by smtp_connection.id' do
      let!(:smtp_connection) { create(:smtp_connection) }
      let!(:other_smtp_connection) { create(:smtp_connection) }
      let!(:contractors) { create_list(:contractor, 3, vendor: true, smtp_connection: smtp_connection) }
      before { create(:vendor, smtp_connection: other_smtp_connection) }

      let(:request_params) do
        { filter: { 'smtp_connection.id': smtp_connection.id } }
      end

      it 'returns filtered contractors by smtp_connection.id' do
        subject
        expect(response.status).to eq(200)
        actual_ids = response_json[:data].map { |r| r[:id] }
        expect(actual_ids).to match_array contractors.map(&:id).map(&:to_s)
      end
    end
  end
end
