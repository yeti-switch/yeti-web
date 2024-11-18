# frozen_string_literal: true

RSpec.shared_context :acceptance_admin_user do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:admin_user) { create :admin_user }

  let(:auth_token) do
    Authentication::AdminAuth.build_auth_data(admin_user).token
  end
end
