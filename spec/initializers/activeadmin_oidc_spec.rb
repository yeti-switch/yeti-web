# frozen_string_literal: true

require 'tempfile'

RSpec.describe 'config/initializers/activeadmin_oidc.rb' do
  let(:initializer_path) { Rails.root.join('config/initializers/activeadmin_oidc.rb') }

  let(:yaml_body) do
    <<~YAML
      development: &default
        issuer: https://idp.example.com
        client_id: test-client
        client_secret:
        scope: openid profile email
        identity_claim: preferred_username
        roles_claim: roles
        default_roles:
          - admin

      test:
        <<: *default
    YAML
  end

  # Drive the initializer without touching the real config/oidc.yml or the
  # real ActiveAdmin::Oidc singleton — we just want to capture the configured
  # on_login lambda and prove it does what we say it does.
  def load_initializer_with(yaml_body, file_exists: true)
    stub_const('ActiveAdmin::Oidc', Module.new)
    captured = Class.new do
      attr_accessor :issuer, :client_id, :client_secret, :scope,
                    :identity_attribute, :identity_claim, :admin_user_class,
                    :on_login
    end.new
    allow(ActiveAdmin::Oidc).to receive(:configure).and_yield(captured)

    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with(Rails.root.join('config/oidc.yml')).and_return(file_exists)

    if file_exists
      allow(YAML).to receive(:load_file)
        .with(Rails.root.join('config/oidc.yml'), aliases: true)
        .and_return(YAML.safe_load(yaml_body, aliases: true))
    end

    load initializer_path.to_s
    captured
  end

  context 'when config/oidc.yml is absent' do
    it 'does not call ActiveAdmin::Oidc.configure' do
      stub_const('ActiveAdmin::Oidc', Module.new)
      expect(ActiveAdmin::Oidc).not_to receive(:configure)
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with(Rails.root.join('config/oidc.yml')).and_return(false)
      load initializer_path.to_s
    end
  end

  context 'when config/oidc.yml is present' do
    subject(:configured) { load_initializer_with(yaml_body) }

    # The on_login lambda calls AdminUser.available_roles to intersect
    # claimed roles with the host app's configured policy roles.
    # Stub it so test role names are recognized.
    before do
      allow(AdminUser).to receive(:available_roles)
        .and_return(%i[admin user ops eng dev viewer reporter root])
    end

    it 'reads issuer / client_id / scope from yaml' do
      expect(configured.issuer).to eq('https://idp.example.com')
      expect(configured.client_id).to eq('test-client')
      expect(configured.scope).to eq('openid profile email')
    end

    it 'leaves client_secret nil for PKCE public client when yaml value is blank' do
      expect(configured.client_secret).to be_nil
    end

    it 'pins identity_attribute to :username and identity_claim from yaml' do
      expect(configured.identity_attribute).to eq(:username)
      expect(configured.identity_claim).to eq(:preferred_username)
    end

    describe 'on_login lambda' do
      let(:admin_user) do
        double('AdminUser', new_record?: true, persisted?: false).tap do |u|
          allow(u).to receive(:roles=)
          allow(u).to receive(:email=)
          allow(u).to receive(:enabled=)
        end
      end

      it 'maps flat roles claim onto admin_user.roles' do
        expect(admin_user).to receive(:roles=).with(%w[ops eng])
        configured.on_login.call(admin_user, 'roles' => %w[ops eng], 'email' => 'x@y')
      end

      it 'falls back to default_roles when roles claim is empty' do
        expect(admin_user).to receive(:roles=).with(%w[admin])
        configured.on_login.call(admin_user, 'roles' => [], 'email' => 'x@y')
      end

      it 'falls back to default_roles when roles claim is missing' do
        expect(admin_user).to receive(:roles=).with(%w[admin])
        configured.on_login.call(admin_user, 'email' => 'x@y')
      end

      it 'assigns email when claim is present' do
        expect(admin_user).to receive(:email=).with('x@y')
        configured.on_login.call(admin_user, 'email' => 'x@y')
      end

      it 'does not assign email when claim is blank' do
        expect(admin_user).not_to receive(:email=)
        configured.on_login.call(admin_user, 'email' => '')
      end

      it 'enables a new record' do
        expect(admin_user).to receive(:enabled=).with(true)
        configured.on_login.call(admin_user, {})
      end

      it 'does not touch enabled on an existing record' do
        allow(admin_user).to receive(:new_record?).and_return(false)
        allow(admin_user).to receive(:persisted?).and_return(true)
        allow(admin_user).to receive(:enabled?).and_return(true)
        expect(admin_user).not_to receive(:enabled=)
        configured.on_login.call(admin_user, {})
      end

      it 'returns true on the happy path' do
        expect(configured.on_login.call(admin_user, 'email' => 'x@y')).to be(true)
      end
    end

    context 'with a custom roles_claim' do
      let(:yaml_body) do
        <<~YAML
          test:
            issuer: https://idp.example.com
            client_id: test-client
            default_roles:
              - admin
            roles_claim: groups
        YAML
      end

      it 'reads the custom claim name' do
        admin_user = double('AdminUser', new_record?: true, persisted?: false).tap do |u|
          allow(u).to receive(:roles=)
          allow(u).to receive(:email=)
          allow(u).to receive(:enabled=)
        end
        expect(admin_user).to receive(:roles=).with(%w[dev])
        configured.on_login.call(admin_user, 'groups' => %w[dev])
      end
    end

    context 'with a Zitadel-shaped roles claim' do
      let(:yaml_body) do
        <<~YAML
          test:
            issuer: https://idp.example.com
            client_id: test-client
            default_roles:
              - admin
            roles_claim: "urn:zitadel:iam:org:project:roles"
        YAML
      end

      let(:admin_user) do
        double('AdminUser', new_record?: true, persisted?: false).tap do |u|
          allow(u).to receive(:roles=)
          allow(u).to receive(:email=)
          allow(u).to receive(:enabled=)
        end
      end

      it 'flattens the nested hash keys into a flat role array' do
        zitadel_claims = {
          'urn:zitadel:iam:org:project:roles' => {
            'ops' => { '123456789' => 'acme.zitadel.cloud' },
            'viewer' => { '123456789' => 'acme.zitadel.cloud' }
          }
        }
        expect(admin_user).to receive(:roles=).with(%w[ops viewer])
        configured.on_login.call(admin_user, zitadel_claims)
      end

      it 'falls back to default_roles when the Zitadel hash is empty' do
        expect(admin_user).to receive(:roles=).with(%w[admin])
        configured.on_login.call(admin_user, 'urn:zitadel:iam:org:project:roles' => {})
      end

      it 'falls back to default_roles when the Zitadel claim is missing' do
        expect(admin_user).to receive(:roles=).with(%w[admin])
        configured.on_login.call(admin_user, {})
      end
    end
  end
end
