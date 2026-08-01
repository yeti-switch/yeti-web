# frozen_string_literal: true

# Covers the AA "OAuth Applications" page: registering a client, reading its
# credentials back, rotating the secret, deletion, and role gating.
RSpec.describe 'OAuth Applications page', :js do
  include_context :with_oauth_routes

  let!(:application) do
    create_oauth_application(
      name: 'yeti-statistics',
      confidential: true,
      scopes: 'openid profile email',
      redirect_uri: 'https://stats.example.com/api/auth/callback'
    )
  end

  context 'as an admin whose role allows access' do
    include_context :login_as_admin

    it 'lists registered clients with their client id' do
      visit oauth_applications_path
      expect(page).to have_content('yeti-statistics')
      expect(page).to have_content(application.uid)
    end

    # The whole point of the page: Doorkeeper stores the secret in cleartext and
    # an operator configuring a client has to read it back.
    it 'shows the client secret on the detail page' do
      visit oauth_application_path(application)
      expect(page).to have_content(application.uid)
      expect(page).to have_content(application.plaintext_secret)
    end

    it 'registers a new client with a generated client id and secret' do
      visit new_oauth_application_path
      fill_in 'Name', with: 'grafana'
      fill_in 'Redirect uri', with: 'https://grafana.example.com/login/generic_oauth'
      check 'openid'
      click_button 'Create'

      created = OauthApplication.find_by(name: 'grafana')
      expect(created).to be_present
      expect(created.uid).to be_present
      expect(created.plaintext_secret).to be_present
      expect(created.scopes.to_a).to include('openid')
    end

    # Deployments that template the client config from one variable need to pin
    # the credentials rather than copy generated ones back out.
    it 'accepts a chosen client id and secret' do
      visit new_oauth_application_path
      fill_in 'Name', with: 'templated-client'
      fill_in 'Redirect uri', with: 'https://tpl.example.com/callback'
      fill_in 'Client ID', with: 'my-fixed-client-id'
      fill_in 'Client secret', with: 'my-fixed-client-secret'
      check 'openid'
      click_button 'Create'

      created = OauthApplication.find_by(name: 'templated-client')
      expect(created.uid).to eq('my-fixed-client-id')
      expect(created.plaintext_secret).to eq('my-fixed-client-secret')
    end

    it 'rejects a non-loopback redirect uri that is not HTTPS' do
      visit new_oauth_application_path
      fill_in 'Name', with: 'insecure'
      fill_in 'Redirect uri', with: 'http://stats.example.com/callback'
      click_button 'Create'

      expect(OauthApplication.find_by(name: 'insecure')).to be_nil
      expect(page).to have_content(/redirect uri/i)
    end

    it 'rotates the client secret, leaving the client id alone' do
      old_secret = application.plaintext_secret
      visit oauth_application_path(application)
      accept_confirm { click_link 'Rotate secret' }

      expect(page).to have_content('Client secret rotated')
      application.reload
      expect(application.plaintext_secret).not_to eq(old_secret)
      expect(application.uid).to eq(application.reload.uid)
    end

    # The uid is not offered on edit — changing it would break a client that is
    # already configured with it.
    it 'does not offer the client id for editing' do
      visit edit_oauth_application_path(application)
      expect(page).to have_field('Name')
      expect(page).to have_no_field('Client ID')
      expect(page).to have_no_field('Client secret')
    end
  end

  context 'as an admin whose role denies access' do
    include_context :login_as_admin

    before do
      policy_roles = Rails.configuration.policy_roles.deep_merge(
        user: { :'System/OauthApplication' => { read: false } }
      )
      allow(Rails.configuration).to receive(:policy_roles).and_return(policy_roles)
    end

    it 'is redirected away from the page, so secrets stay hidden' do
      visit oauth_applications_path
      expect(page).to have_current_path(root_path)
      expect(page).not_to have_content(application.plaintext_secret)
    end
  end
end
