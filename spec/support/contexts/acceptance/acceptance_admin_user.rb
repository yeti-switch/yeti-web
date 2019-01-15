# frozen_string_literal: true

RSpec.shared_context :acceptance_admin_user do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }

  let(:auth_token) do
    ::Knock::AuthToken.new(payload: { sub: user.id }).token
  end
end
