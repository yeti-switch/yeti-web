# frozen_string_literal: true

# Exercises the full OmniAuth callback → on_login → AdminUser flow under
# OIDC mode. Runs only when CI_RUN_OIDC=true and config/oidc.yml is present
# (see spec/support/oidc_mode.rb).
RSpec.describe 'OIDC sign-in', type: :feature, oidc_mode: true do
  before do
    allow_any_instance_of(ActiveAdmin::PagePolicy).to receive(:show?).and_return(true)
  end

  def click_sso_button
    visit new_admin_user_session_path
    click_button(ActiveAdmin::Oidc.config.login_button_label)
  end

  context 'first-time sign-in (JIT provisioning)' do
    let(:claims) do
      {
        'preferred_username' => 'alice',
        'email' => 'alice@test.com',
        'roles' => ['root']
      }
    end

    before { stub_oidc_sign_in(sub: 'alice-sub', claims: claims) }

    it 'creates an AdminUser with mapped claims and billing_contact email' do
      expect {
        click_sso_button
      }.to change { AdminUser.count }.by(1)

      created = AdminUser.find_by!(username: 'alice')
      expect(created).to have_attributes(
        provider: 'oidc',
        uid: 'alice-sub',
        roles: ['root'],
        enabled: true
      )
      expect(created.billing_contact.email).to eq('alice@test.com')
      expect(created.oidc_raw_info).to include('preferred_username' => 'alice', 'email' => 'alice@test.com')
      expect(created.oidc_raw_info.keys).not_to include('access_token', 'refresh_token', 'id_token')
      expect(page).to have_current_path('/admin', ignore_query: true)
    end
  end

  context 'second sign-in via (provider, uid)' do
    let!(:existing) do
      create(:admin_user, :filled,
             username: 'alice',
             provider: 'oidc',
             uid: 'alice-sub',
             roles: %w[root])
    end

    before do
      stub_oidc_sign_in(
        sub: 'alice-sub',
        claims: { 'preferred_username' => 'alice', 'email' => 'alice@test.com', 'roles' => ['root'] }
      )
    end

    it 'does not create a new AdminUser and refreshes roles' do
      expect { click_sso_button }.not_to change { AdminUser.count }
      expect(existing.reload.roles).to eq(['root'])
    end
  end

  context 'adoption of a DB-only row by identity_attribute' do
    let!(:legacy) do
      create(:admin_user, :filled,
             username: 'alice',
             provider: nil,
             uid: nil,
             roles: %w[root])
    end

    before do
      stub_oidc_sign_in(
        sub: 'alice-sub',
        claims: { 'preferred_username' => 'alice', 'email' => 'alice@test.com', 'roles' => ['root'] }
      )
    end

    it 'populates provider/uid without creating a new row' do
      expect { click_sso_button }.not_to change { AdminUser.count }
      legacy.reload
      expect(legacy.provider).to eq('oidc')
      expect(legacy.uid).to eq('alice-sub')
    end
  end

  context 'empty roles claim' do
    before do
      stub_oidc_sign_in(sub: 'alice-sub', claims: { 'roles' => [], 'email' => 'alice@test.com' })
    end

    it 'falls back to default_roles from config' do
      click_sso_button
      created = AdminUser.find_by!(username: 'alice')
      expect(created.roles).to eq(['root'])
    end
  end

  context 'disabled user' do
    let!(:existing) do
      create(:admin_user, :filled,
             username: 'alice',
             provider: 'oidc',
             uid: 'alice-sub',
             enabled: false,
             roles: %w[root])
    end

    before do
      stub_oidc_sign_in(sub: 'alice-sub', claims: { 'preferred_username' => 'alice' })
    end

    it 'is not signed in' do
      click_sso_button
      expect(page).to have_current_path(new_admin_user_session_path, ignore_query: true)
    end
  end

  context 'IP allowlist blocks the request' do
    let!(:existing) do
      create(:admin_user, :filled,
             username: 'alice',
             provider: 'oidc',
             uid: 'alice-sub',
             allowed_ips: ['10.0.0.0/8'],
             roles: %w[root])
    end

    before do
      stub_oidc_sign_in(sub: 'alice-sub', claims: { 'preferred_username' => 'alice' })
    end

    it 'denies sign-in from a disallowed IP' do
      click_sso_button
      expect(page).to have_current_path(new_admin_user_session_path, ignore_query: true)
    end
  end
end
