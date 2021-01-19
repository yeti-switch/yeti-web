# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::Cdr::AuthLogsController, type: :request do
  include_context :json_api_admin_helpers, type: :'auth-logs', prefix: '/api/rest/admin/cdr'

  describe 'GET /api/rest/admin/cdr/auth-logs' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let!(:auth_logs) do
      Cdr::AuthLog.all
    end

    include_examples :jsonapi_responds_with_pagination_links
    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) do
        auth_logs.map { |r| r.id.to_s }
      end
    end
  end
end
