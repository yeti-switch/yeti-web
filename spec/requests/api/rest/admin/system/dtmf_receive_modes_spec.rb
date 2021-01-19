# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::System::DtmfReceiveModesController, type: :request do
  include_context :json_api_admin_helpers, type: :'dtmf-receive-modes', prefix: '/api/rest/admin/system'

  describe 'GET /api/rest/admin/system/dtmf-receive-modes' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let!(:dtmf_receive_modes) do
      System::DtmfReceiveMode.all
    end

    include_examples :jsonapi_responds_with_pagination_links
    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) do
        dtmf_receive_modes.map { |r| r.id.to_s }
      end
    end
  end
end
