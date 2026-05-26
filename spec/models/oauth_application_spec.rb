# frozen_string_literal: true

RSpec.describe OauthApplication do
  describe 'persistence in gui schema' do
    it 'uses gui.oauth_applications as the table' do
      expect(described_class.table_name).to eq('gui.oauth_applications')
    end

    it 'creates a row and auto-generates uid + secret' do
      app = described_class.create!(
        name: 'Claude Code',
        redirect_uri: 'http://localhost:8080/callback',
        scopes: 'mcp',
        confidential: false
      )
      expect(app.uid).to be_present
      expect(app.secret).to be_present
      expect(described_class.find(app.id).name).to eq('Claude Code')
    end

    it 'defaults confidential=true and empty scopes' do
      app = described_class.create!(name: 'X', redirect_uri: 'http://localhost/cb')
      expect(app.confidential).to be true
      expect(app.scopes.to_s).to eq('')
    end
  end

  describe 'Doorkeeper class indirection' do
    it 'is what Doorkeeper resolves to as application_class' do
      expect(Doorkeeper.config.application_class.to_s).to eq('OauthApplication')
    end

    it 'is findable via the custom class after creation' do
      app = described_class.create!(name: 'Y', redirect_uri: 'http://localhost/cb2')
      expect(described_class.find_by(uid: app.uid)).to eq(app)
    end
  end
end
