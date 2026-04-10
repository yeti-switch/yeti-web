# frozen_string_literal: true

RSpec.describe 'OIDC routes', type: :request, oidc_mode: true do
  it 'recognizes the omniauth request path' do
    # OmniAuth routes are Rack middleware, not standard Rails routes,
    # so we verify by making an actual request rather than route_to.
    post '/admin/auth/oidc'
    # OmniAuth will redirect to the IdP or return a non-404 response
    expect(response.status).not_to eq(404)
  end

  it 'recognizes the omniauth callback path' do
    expect { get '/admin/auth/oidc/callback' }.not_to raise_error
  end

  it 'mounts omniauth under the /admin/auth prefix' do
    expect(Devise.omniauth_path_prefix).to eq('/admin/auth')
  end

  it 'has loaded the OIDC concern on AdminUser' do
    expect(AdminUser).to be_oidc
  end
end
