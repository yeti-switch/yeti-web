# frozen_string_literal: true

RSpec.describe 'OIDC sessions page', type: :feature, oidc_mode: true do
  it 'renders the SSO login button on the Devise sign-in page' do
    visit new_admin_user_session_path
    expect(page).to have_button(ActiveAdmin::Oidc.configuration.login_button_label)
  end

  it 'does NOT render the username/password form in OIDC mode' do
    visit new_admin_user_session_path
    # Devise's password field + submit button must both be absent so that
    # an admin accidentally landing on /login cannot attempt DB auth.
    expect(page).not_to have_field('admin_user[password]')
    expect(page).not_to have_css('form#session_new')
  end

  # Regression: in OIDC mode, hitting `/` while unauthenticated used to
  # redirect to `/` infinitely because `:database_authenticatable` had
  # been dropped from the concern and Devise consequently did not mount
  # the sessions controller, so there was no `/login` landing page and
  # Warden's auth failure redirect fell back to `/` — a loop.
  it 'redirects an unauthenticated root request to the sign-in page (not a redirect loop)' do
    visit '/'
    expect(page).to have_current_path(new_admin_user_session_path, ignore_query: true)
    expect(page).to have_button(ActiveAdmin::Oidc.configuration.login_button_label)
  end

  it 'posts (not GETs) the SSO button — button_to with CSRF token' do
    visit new_admin_user_session_path
    button = find_button(ActiveAdmin::Oidc.configuration.login_button_label)
    form = button.ancestor('form')
    expect(form['method']).to match(/post/i)
    expect(form['action']).to eq('/admin/auth/oidc')
  end
end
