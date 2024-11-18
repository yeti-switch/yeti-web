# frozen_string_literal: true

RSpec.shared_context :jsonapi_admin_headers do
  let(:admin_user) { create :admin_user }

  let(:auth_token) do
    Authentication::AdminAuth.build_auth_data(admin_user).token
  end

  before do
    request.accept = 'application/vnd.api+json'
    request.headers['Content-Type'] = 'application/vnd.api+json'
    request.headers['Authorization'] = auth_token
  end
end
