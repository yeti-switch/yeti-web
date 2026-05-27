# frozen_string_literal: true

# == Schema Information
#
# Table name: gui.oauth_access_grants
#
#  id                    :bigint(8)        not null, primary key
#  code_challenge        :string
#  code_challenge_method :string
#  expires_in            :integer(4)       not null
#  redirect_uri          :text             not null
#  revoked_at            :timestamptz
#  scopes                :string           default(""), not null
#  token                 :string           not null
#  created_at            :timestamptz      not null
#  application_id        :bigint(8)        not null
#  resource_owner_id     :bigint(8)        not null
#
# Indexes
#
#  index_oauth_access_grants_on_application_id     (application_id)
#  index_oauth_access_grants_on_resource_owner_id  (resource_owner_id)
#  index_oauth_access_grants_on_token              (token) UNIQUE
#
# Foreign Keys
#
#  oauth_access_grants_application_id_fkey     (application_id => oauth_applications.id)
#  oauth_access_grants_resource_owner_id_fkey  (resource_owner_id => admin_users.id) ON DELETE => cascade
#
RSpec.describe OauthAccessGrant do
  let(:admin) { create(:admin_user) }
  let(:application) { create_oauth_application }

  it 'uses gui.oauth_access_grants as the table' do
    expect(described_class.table_name).to eq('gui.oauth_access_grants')
  end

  it 'is what Doorkeeper::AccessGrant resolves to' do
    expect(Doorkeeper.config.access_grant_class.to_s).to eq('OauthAccessGrant')
  end

  it 'creates a row' do
    grant = described_class.create!(
      resource_owner_id: admin.id,
      application: application,
      expires_in: 600,
      redirect_uri: 'http://localhost/cb',
      token: SecureRandom.hex(16)
    )
    expect(described_class.find(grant.id)).to eq(grant)
  end

  it 'cascades on AdminUser delete' do
    grant = described_class.create!(
      resource_owner_id: admin.id,
      application: application,
      expires_in: 600,
      redirect_uri: 'http://localhost/cb',
      token: SecureRandom.hex(16)
    )
    grant_id = grant.id
    admin.destroy
    expect(described_class.find_by(id: grant_id)).to be_nil
  end
end
