# frozen_string_literal: true

# Dummy AR model lets us exercise the concern independently of the real
# AdminUser's file-gated auth-mode selection, so these specs can run in
# the default DB suite.
ActiveRecord::Schema.define do
  self.verbose = false
  create_table :dummy_oidc_users, force: true do |t|
    t.string :username
    t.string :encrypted_password, default: '', null: false
    t.string :provider
    t.string :uid
    t.jsonb  :oidc_raw_info
    t.inet   :allowed_ips, array: true
    t.integer :sign_in_count, default: 0
    t.datetime :current_sign_in_at
    t.datetime :last_sign_in_at
    t.string :current_sign_in_ip
    t.string :last_sign_in_ip
    t.timestamps
  end
end

class DummyOidcUser < ActiveRecord::Base
  self.table_name = 'dummy_oidc_users'
  include AdminUserOidcHandler
end

RSpec.describe AdminUserOidcHandler do
  describe 'devise modules' do
    subject(:modules) { DummyOidcUser.devise_modules }

    it { is_expected.to include(:omniauthable) }
    it { is_expected.to include(:trackable) }
    it { is_expected.to include(:ip_allowable) }
    # :database_authenticatable is kept so Devise mounts the sessions
    # controller, giving us a /login landing page for the SSO button.
    it { is_expected.to include(:database_authenticatable) }
    it { is_expected.not_to include(:ldap_authenticatable) }
  end

  it 'registers the :oidc omniauth provider' do
    expect(DummyOidcUser.omniauth_providers).to eq([:oidc])
  end

  describe '#valid_password?' do
    # Database login is disabled in OIDC mode — the concern keeps
    # :database_authenticatable purely so Devise mounts the sessions
    # controller, but any actual password check must always fail so
    # that a direct POST to /admin/admin_users/sign_in can't sneak in.
    it 'always returns false regardless of the stored password' do
      user = DummyOidcUser.new(username: 'alice')
      user.encrypted_password = 'anything'
      expect(user.valid_password?('anything')).to be(false)
      expect(user.valid_password?('')).to be(false)
    end
  end

  describe 'oidc_raw_info serialization' do
    it 'round-trips a hash through JSON' do
      user = DummyOidcUser.new(username: 'alice')
      user.oidc_raw_info = { 'sub' => 'abc', 'email' => 'a@b' }
      user.save!(validate: false)
      expect(user.reload.oidc_raw_info).to eq('sub' => 'abc', 'email' => 'a@b')
    end
  end
end
