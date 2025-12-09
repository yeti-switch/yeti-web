# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::TimezonesController, type: :request do
  include_context :json_api_admin_helpers, type: :timezones

  describe 'GET /api/rest/admin/timezones' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let!(:timezones) { Yeti::TimeZoneHelper.all }

    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) { timezones }
    end

    it_behaves_like :json_api_admin_check_authorization
  end
end
