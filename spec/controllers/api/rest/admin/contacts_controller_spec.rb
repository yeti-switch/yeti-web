# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::ContactsController, type: :controller do
  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }

  before do
    request.accept = 'application/vnd.api+json'
    request.headers['Content-Type'] = 'application/vnd.api+json'
    request.headers['Authorization'] = auth_token
  end

  describe 'GET index with ransack filters' do
    let(:factory) { :contact }

    it_behaves_like :jsonapi_filters_by_string_field, :email
    it_behaves_like :jsonapi_filters_by_string_field, :notes
  end
end
