# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::CodecGroupsController, type: :request do
  include_context :json_api_admin_helpers, type: :'codec-groups'

  describe 'GET /api/rest/admin/codec-groups' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let!(:codec_groups) do
      FactoryBot.create_list(:codec_group, 2)
    end

    include_examples :jsonapi_responds_with_pagination_links
    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) do
        codec_groups.map { |r| r.id.to_s }
      end
    end
  end
end
