# frozen_string_literal: true

RSpec.describe OauthAccessTokenPolicy do
  let(:admin_user) { FactoryBot.build(:admin_user, roles: user_roles) }
  let(:policy) { described_class.new(admin_user, OauthAccessToken.new) }

  before do
    allow(Rails.configuration).to receive(:policy_roles).and_return(policy_roles_config)
  end

  # Page-level access is role-based (config/policy_roles.yml, section
  # "System/OauthAccessToken"): `read` gates seeing the page, `remove`
  # gates revoking. There is no owner scoping.
  describe '#read?' do
    context 'when AdminUser is root' do
      let(:user_roles) { [:root] }
      let(:policy_roles_config) { {} }

      it { expect(policy.read?).to be true }
    end

    context 'when the role allows read in the section' do
      let(:user_roles) { [:user] }
      let(:policy_roles_config) { { user: { :'System/OauthAccessToken' => { read: true } } } }

      it { expect(policy.read?).to be true }
    end

    context 'when the role disallows read in the section' do
      let(:user_roles) { [:user] }
      let(:policy_roles_config) { { user: { :'System/OauthAccessToken' => { read: false } } } }

      it { expect(policy.read?).to be false }
    end

    context 'when the section is absent (falls back to the Default section)' do
      let(:user_roles) { [:user] }
      let(:policy_roles_config) { { user: { Default: { read: true } } } }

      it { expect(policy.read?).to be true }
    end
  end

  describe '#destroy?' do
    let(:user_roles) { [:user] }

    context 'when the role allows remove in the section' do
      let(:policy_roles_config) { { user: { :'System/OauthAccessToken' => { remove: true } } } }

      it { expect(policy.destroy?).to be true }
    end

    context 'when the role disallows remove in the section' do
      let(:policy_roles_config) { { user: { :'System/OauthAccessToken' => { remove: false } } } }

      it { expect(policy.destroy?).to be false }
    end
  end

  # No owner scoping: anyone who can read the page sees every token, so the
  # scope returns the collection untouched.
  describe described_class::Scope do
    let(:user_roles) { [:user] }
    let(:policy_roles_config) { {} }
    let(:relation) { instance_double(ActiveRecord::Relation) }

    it 'returns the collection unfiltered' do
      expect(described_class.new(admin_user, relation).resolve).to be(relation)
    end
  end
end
