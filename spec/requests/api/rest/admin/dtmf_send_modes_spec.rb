# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::DtmfSendModesController, type: :request do
  include_context :json_api_admin_helpers, type: :'dtmf-send-modes'

  describe 'GET /api/rest/admin/dtmf-send-modes' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let!(:dtmf_send_modes) do
      System::DtmfSendMode.all
    end

    include_examples :jsonapi_responds_with_pagination_links
    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) do
        dtmf_send_modes.map { |r| r.id.to_s }
      end
    end

    it_behaves_like :json_api_admin_check_authorization
  end
end
