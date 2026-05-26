# frozen_string_literal: true

RSpec.describe OauthAccessTokenPolicy do
  let(:owner) { create(:admin_user) }
  let(:other) { create(:admin_user) }
  let(:root_admin) { create(:admin_user, roles: ['root']) }
  let(:application) { create_oauth_application }

  let(:owners_token) do
    OauthAccessToken.create!(
      resource_owner_id: owner.id,
      application: application,
      scopes: 'mcp',
      expires_in: 3600
    )
  end

  describe '#read? / #destroy?' do
    context 'when the actor owns the token' do
      it 'allows read and destroy' do
        policy = described_class.new(owner, owners_token)
        expect(policy.read?).to be true
        expect(policy.destroy?).to be true
      end
    end

    context 'when the actor is another non-root admin' do
      it 'denies read and destroy' do
        policy = described_class.new(other, owners_token)
        expect(policy.read?).to be false
        expect(policy.destroy?).to be false
      end
    end

    context 'when the actor has the root role' do
      it 'allows read and destroy on anyone else’s token' do
        policy = described_class.new(root_admin, owners_token)
        expect(policy.read?).to be true
        expect(policy.destroy?).to be true
      end
    end
  end

  describe described_class::Scope do
    let!(:token_a) do
      OauthAccessToken.create!(resource_owner_id: owner.id, application: application, scopes: 'mcp', expires_in: 3600)
    end
    let!(:token_b) do
      OauthAccessToken.create!(resource_owner_id: other.id, application: application, scopes: 'mcp', expires_in: 3600)
    end

    it 'narrows to the actor’s own tokens for a non-root admin' do
      resolved = described_class.new(owner, OauthAccessToken).resolve
      expect(resolved).to contain_exactly(token_a)
    end

    it 'returns all tokens for a root admin' do
      resolved = described_class.new(root_admin, OauthAccessToken).resolve
      expect(resolved).to contain_exactly(token_a, token_b)
    end
  end
end
