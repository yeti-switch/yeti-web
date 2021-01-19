# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::System::SipSchemasController, type: :request do
  include_context :json_api_admin_helpers, type: :'sip-schemas', prefix: '/api/rest/admin/system'

  describe 'GET /api/rest/admin/system/sip-schemas' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let!(:sip_schemas) do
      System::SipSchema.all
    end

    include_examples :jsonapi_responds_with_pagination_links
    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) do
        sip_schemas.map { |r| r.id.to_s }
      end
    end
  end
end
