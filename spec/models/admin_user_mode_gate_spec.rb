# frozen_string_literal: true

RSpec.describe AdminUser, 'auth-mode gate' do
  describe '.oidc_config' do
    it 'points at config/oidc.yml under Rails.root' do
      expect(described_class.oidc_config).to eq(Rails.root.join('config/oidc.yml'))
    end
  end

  describe '.oidc_config_exists?' do
    it 'delegates to File.exist?' do
      expect(File).to receive(:exist?).with(described_class.oidc_config).and_return(true)
      expect(described_class.oidc_config_exists?).to be(true)
    end
  end

  describe '.external_auth?' do
    it 'returns true when ldap? is true' do
      allow(described_class).to receive(:ldap?).and_return(true)
      allow(described_class).to receive(:oidc?).and_return(false)
      expect(described_class.external_auth?).to be(true)
    end

    it 'returns true when oidc? is true' do
      allow(described_class).to receive(:ldap?).and_return(false)
      allow(described_class).to receive(:oidc?).and_return(true)
      expect(described_class.external_auth?).to be(true)
    end

    it 'returns false when both are false' do
      allow(described_class).to receive(:ldap?).and_return(false)
      allow(described_class).to receive(:oidc?).and_return(false)
      expect(described_class.external_auth?).to be(false)
    end
  end

  describe 'precedence in source' do
    # Meta-test guarding against accidental reorder of the if/elsif/else
    # gate in admin_user.rb. OIDC must win when both files exist.
    it 'puts the OIDC branch above the LDAP branch' do
      source = File.read(Rails.root.join('app/models/admin_user.rb'))
      oidc_idx = source.index('if oidc_config_exists?')
      ldap_idx = source.index('elsif ldap_config_exists?')
      expect(oidc_idx).not_to be_nil
      expect(ldap_idx).not_to be_nil
      expect(oidc_idx).to be < ldap_idx
    end
  end

  context 'in the default DB test suite' do
    it 'is not in OIDC mode' do
      expect(described_class.oidc?).to be(false)
    end
  end
end
