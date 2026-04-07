# frozen_string_literal: true

RSpec.describe 'Show Gateway', type: :feature, js: true do
  subject do
    visit gateway_path(gateway.id)
  end

  include_context :login_as_admin

  let!(:node) { FactoryBot.create(:node) }
  let!(:vendor) { FactoryBot.create(:vendor) }
  let!(:gateway_group) { FactoryBot.create(:gateway_group, vendor: vendor) }
  let!(:gateway) { FactoryBot.create(:gateway, *gateway_traits, **gateway_attrs) }
  let(:gateway_traits) { [:filled] }
  let(:gateway_attrs) { { contractor: vendor, gateway_group: } }

  it 'shows gateway details page' do
    subject
    expect(page).to have_attribute_row('ID', exact_text: gateway.id)
  end

  describe 'incoming registrations tab' do
    context 'when node is active' do
      let(:registration_data) { FactoryBot.attributes_for(:incoming_registration, :filled).stringify_keys }

      before do
        stub_jrpc_request(node.rpc_endpoint, 'registrar.show.aors', [gateway.id]).and_return([registration_data])
        subject
        switch_tab('Incoming Registrations')
      end

      it 'shows json payload' do
        expect(page).to have_css('pre code.json')
        expect(page).to have_content(registration_data['contact'])
      end
    end

    context 'when node is turned off' do
      before do
        stub_jrpc_connect_error(node.rpc_endpoint)
        subject
        switch_tab('Incoming Registrations')
      end

      it 'shows error in json' do
        expect(page).to have_css('pre code.json')
        expect(page).to have_content("can't connect to #{node.rpc_endpoint}")
      end
    end
  end

  context 'none external gateway incoming auth fields' do
    let(:gateway_traits) { super() + [:with_incoming_auth] }
    let(:gateway_attrs) { super().merge(external_id: nil) }

    it 'shows gateway details page' do
      subject

      expect(page).to have_attribute_row('ID', exact_text: gateway.id)
      switch_tab('Signaling')
      expect(page).to have_attribute_row('Incoming Auth Username', exact_text: gateway.incoming_auth_username)
      expect(page).to have_attribute_row('Incoming Auth Password', exact_text: gateway.incoming_auth_password)
    end
  end

  context 'external gateway incoming auth fields' do
    let(:gateway_traits) { super() + [:with_incoming_auth] }
    let(:gateway_attrs) { super() }

    it 'shows gateway details page' do
      subject

      expect(page).to have_attribute_row('ID', exact_text: gateway.id)
      switch_tab('Signaling')
      expect(page).not_to have_attribute_row('Incoming Auth Username')
      expect(page).not_to have_attribute_row('Incoming Auth Password')
    end

    context 'when user have policy to allow_incoming_auth_credentials' do
      before do
        policy_roles = Rails.configuration.policy_roles.deep_merge(
          user: { :Gateway => { allow_incoming_auth_credentials: true } }
        )
        allow(Rails.configuration).to receive(:policy_roles).and_return(policy_roles)
      end

      it 'should display credential fields' do
        subject

        expect(page).to have_attribute_row('ID', exact_text: gateway.id)
        switch_tab('Signaling')
        expect(page).to have_attribute_row('Incoming Auth Username', exact_text: gateway.incoming_auth_username)
        expect(page).to have_attribute_row('Incoming Auth Password', exact_text: gateway.incoming_auth_password)
      end
    end
  end
end
