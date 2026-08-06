# frozen_string_literal: true

RSpec.describe OauthApplicationPolicy do
  let(:admin_user) { FactoryBot.build(:admin_user, roles: user_roles) }
  let(:policy) { described_class.new(admin_user, OauthApplication.new) }

  before do
    allow(Rails.configuration).to receive(:policy_roles).and_return(policy_roles_config)
  end

  # Page-level access is role-based (config/policy_roles.yml, section
  # "System/OauthApplication"): `read` gates seeing the page — and therefore
  # every client secret on it — `change` gates registering and editing,
  # `remove` gates deletion, `perform` gates rotating a secret.
  describe '#read?' do
    context 'when AdminUser is root' do
      let(:user_roles) { [:root] }
      let(:policy_roles_config) { {} }

      it { expect(policy.read?).to be true }
    end

    context 'when the role allows read in the section' do
      let(:user_roles) { [:user] }
      let(:policy_roles_config) { { user: { :'System/OauthApplication' => { read: true } } } }

      it { expect(policy.read?).to be true }
    end

    context 'when the role disallows read in the section' do
      let(:user_roles) { [:user] }
      let(:policy_roles_config) { { user: { :'System/OauthApplication' => { read: false } } } }

      it { expect(policy.read?).to be false }
    end

    context 'when the section is absent (falls back to the Default section)' do
      let(:user_roles) { [:user] }
      let(:policy_roles_config) { { user: { Default: { read: true } } } }

      it { expect(policy.read?).to be true }
    end
  end

  describe '#create?' do
    context 'when the role allows change' do
      let(:user_roles) { [:user] }
      let(:policy_roles_config) { { user: { :'System/OauthApplication' => { change: true } } } }

      it { expect(policy.create?).to be true }
    end

    context 'when the role only allows read' do
      let(:user_roles) { [:user] }
      let(:policy_roles_config) { { user: { :'System/OauthApplication' => { read: true, change: false } } } }

      it { expect(policy.create?).to be false }
    end
  end

  describe '#destroy?' do
    context 'when the role allows remove' do
      let(:user_roles) { [:user] }
      let(:policy_roles_config) { { user: { :'System/OauthApplication' => { remove: true } } } }

      it { expect(policy.destroy?).to be true }
    end

    context 'when the role disallows remove' do
      let(:user_roles) { [:user] }
      let(:policy_roles_config) { { user: { :'System/OauthApplication' => { remove: false } } } }

      it { expect(policy.destroy?).to be false }
    end
  end

  # Rotating a secret is neither editing a field nor deleting the client, so it
  # rides on `perform` — the same slot other custom AA actions use.
  describe '#rotate_secret?' do
    context 'when the role allows perform' do
      let(:user_roles) { [:user] }
      let(:policy_roles_config) { { user: { :'System/OauthApplication' => { perform: true } } } }

      it { expect(policy.rotate_secret?).to be true }
    end

    context 'when the role allows change but not perform' do
      let(:user_roles) { [:user] }
      let(:policy_roles_config) { { user: { :'System/OauthApplication' => { change: true, perform: false } } } }

      it { expect(policy.rotate_secret?).to be false }
    end
  end
end
