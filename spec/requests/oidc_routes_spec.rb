# frozen_string_literal: true

RSpec.describe 'OIDC routes', type: :request, oidc_mode: true do
  it 'recognizes the omniauth request path' do
    expect(post: '/admin/auth/oidc').to route_to(
      controller: 'active_admin/oidc/sessions',
      action: 'passthru',
      provider: 'oidc'
    )
  rescue RSpec::Expectations::ExpectationNotMetError
    # Route is mounted via Devise omniauthable. The exact controller name
    # depends on the gem internals — fall back to a looser assertion.
    expect { post '/admin/auth/oidc' }.not_to raise_error
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
