# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::RoutesetDiscriminatorsController, type: :request do
  include_context :json_api_admin_helpers, type: :'routeset-discriminators'

  describe 'GET /api/rest/admin/routeset-discriminators' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    before { FactoryBot.create_list(:routeset_discriminator, 2) }
    let!(:routeset_discriminators) do
      Routing::RoutesetDiscriminator.all.to_a
    end

    include_examples :jsonapi_responds_with_pagination_links
    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) do
        routeset_discriminators.map { |r| r.id.to_s }
      end
    end

    it_behaves_like :json_api_admin_check_authorization
  end
end
