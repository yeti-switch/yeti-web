# frozen_string_literal: true

# == Schema Information
#
# Table name: gui.oauth_access_tokens
#
#  id                     :bigint(8)        not null, primary key
#  expires_in             :integer(4)
#  previous_refresh_token :string           default(""), not null
#  refresh_token          :string
#  revoked_at             :timestamptz
#  scopes                 :string
#  token                  :string           not null
#  created_at             :timestamptz      not null
#  application_id         :bigint(8)        not null
#  resource_owner_id      :bigint(8)
#
# Indexes
#
#  index_oauth_access_tokens_on_application_id     (application_id)
#  index_oauth_access_tokens_on_refresh_token      (refresh_token) UNIQUE
#  index_oauth_access_tokens_on_resource_owner_id  (resource_owner_id)
#  index_oauth_access_tokens_on_token              (token) UNIQUE
#
# Foreign Keys
#
#  oauth_access_tokens_application_id_fkey     (application_id => oauth_applications.id)
#  oauth_access_tokens_resource_owner_id_fkey  (resource_owner_id => admin_users.id) ON DELETE => cascade
#
RSpec.describe OauthAccessToken do
  let(:admin) { create(:admin_user) }
  let(:application) { create_oauth_application }

  describe 'persistence in gui schema' do
    it 'uses gui.oauth_access_tokens as the table' do
      expect(described_class.table_name).to eq('gui.oauth_access_tokens')
    end

    it 'is what Doorkeeper resolves to as access_token_class' do
      expect(Doorkeeper.config.access_token_class.to_s).to eq('OauthAccessToken')
    end

    it 'creates a row and is findable via .by_token (plaintext lookup, hashed in DB)' do
      token = OauthAccessToken.create!(
        resource_owner_id: admin.id,
        application: application,
        scopes: 'mcp',
        expires_in: 3600
      )
      # With hash_token_secrets, the `token` column stores SHA256(plaintext).
      # The plaintext is only available via #plaintext_token on the fresh instance.
      expect(OauthAccessToken.by_token(token.plaintext_token)).to eq(token)
    end
  end

  describe '#accessible?' do
    let(:token) { issue_access_token(admin: admin, application: application) }

    it 'is true for a fresh token' do
      expect(token.accessible?).to be true
    end

    it 'is false after revoke' do
      token.revoke
      expect(token.accessible?).to be false
    end

    it 'is false after expiry window passes' do
      token # touch so it's created at "now"
      travel(2.hours) do
        expect(token.reload.accessible?).to be false
      end
    end
  end

  describe 'FK cascade on admin delete' do
    it 'destroys associated tokens when the AdminUser is hard-deleted' do
      token = issue_access_token(admin: admin)
      token_id = token.id
      admin.destroy
      expect(described_class.find_by(id: token_id)).to be_nil
    end
  end
end
