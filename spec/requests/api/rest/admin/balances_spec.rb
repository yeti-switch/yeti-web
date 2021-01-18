# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::AccountsController, type: :request do
  include_context :json_api_admin_helpers, type: :accounts

  describe 'GET /api/rest/admin/accounts/{account_id}/balance' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let(:account_id) { Account.last!.id.to_s }
    let(:json_api_request_path) { "#{super()}/#{account_id}/balance" }

    let!(:accounts) do
      FactoryBot.create_list(:account, 2)
    end

    include_examples :jsonapi_responds_with_pagination_links
    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) do
        accounts.map { |r| r.id.to_s }
      end
    end
  end
end
