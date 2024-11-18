# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::ContactsController, type: :controller do
  include_context :jsonapi_admin_headers

  describe 'GET index with ransack filters' do
    subject do
      get :index, params: json_api_request_query
    end
    let(:factory) { :contact }
    let(:json_api_request_query) { nil }

    it_behaves_like :jsonapi_filters_by_string_field, :email
    it_behaves_like :jsonapi_filters_by_string_field, :notes
  end
end
