# frozen_string_literal: true

RSpec.describe 'Incoming Registrations show', type: :feature, js: true do
  include_context :login_as_admin

  let!(:node) { FactoryBot.create(:node) }
  let!(:gateway) { FactoryBot.create(:gateway) }

  subject { visit incoming_registration_path(gateway.id) }

  context 'when node is active' do
    let(:registration_data) { FactoryBot.attributes_for(:incoming_registration, :filled).stringify_keys }

    before do
      stub_jrpc_request(node.rpc_endpoint, 'registrar.show.aors', [gateway.id]).and_return([registration_data])
    end

    it 'shows json payload' do
      subject
      expect(page).to have_css('pre code.json')
      expect(page).to have_content(registration_data['contact'])
    end
  end

  context 'when node is turned off' do
    before do
      stub_jrpc_connect_error(node.rpc_endpoint)
    end

    it 'shows error in json' do
      subject
      expect(page).to have_css('pre code.json')
      expect(page).to have_content("can't connect to #{node.rpc_endpoint}")
    end
  end
end
