# frozen_string_literal: true

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
