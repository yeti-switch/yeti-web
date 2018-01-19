RSpec.shared_context :jsonapi_admin_headers do

  let(:user) { create :admin_user }

  let(:auth_token) do
    ::Knock::AuthToken.new(payload: { sub: user.id }).token
  end

  before do
    request.accept = 'application/vnd.api+json'
    request.headers['Content-Type'] = 'application/vnd.api+json'
    request.headers['Authorization'] = auth_token
  end
end
