# frozen_string_literal: true

RSpec.describe 'Update Gateway', type: :feature, js: true do
  include_context :login_as_admin

  subject do
    visit edit_gateway_path(gateway.id)
  end

  let!(:gateway) { FactoryBot.create(:gateway, *gateway_traits, **gateway_attrs) }
  let(:gateway_traits) { [] }
  # we have to set external_id to nil because there is UI logic that prevents
  # username/password editing for GWs with not null external id
  let(:gateway_attrs) { { external_id: nil } }

  context 'when gateway has assigned numberlists' do
    let!(:termination_src_numberlist) { FactoryBot.create(:numberlist) }
    let!(:termination_dst_numberlist) { FactoryBot.create(:numberlist) }

    let(:gateway_attrs) { super().merge(termination_src_numberlist:, termination_dst_numberlist:) }

    it 'should display assigned numberlists' do
      subject

      switch_tab('Translations')
      expect(page).to have_field_chosen('Termination SRC Numberlist', with: termination_src_numberlist.display_name)
      expect(page).to have_field_chosen('Termination DST Numberlist', with: termination_dst_numberlist.display_name)
    end
  end

  context 'validate credentials generator' do
    subject do
      super()
      click_on 'Signaling'
    end

    context 'when credentials is empty' do
      let(:gateway_attrs) { super().merge(incoming_auth_username: nil, incoming_auth_password: nil) }

      it 'should generate new credential by click on the link in hint for :incoming_auth_username with 20 chars' do
        subject

        click_link('Сlick to fill random username')
        incoming_auth_username = find_field('gateway_incoming_auth_username')
        expect(incoming_auth_username).to be_present
        expect(incoming_auth_username.value).to be_present
        expect(incoming_auth_username.value).to match(/\A[a-zA-Z0-9]+\z/)
        expect(incoming_auth_username.value.length).to eq(20)
      end

      it 'should generate new credential by click on the link in hint for :incoming_auth_password with 20 chars' do
        subject

        click_link('Сlick to fill random password')
        incoming_auth_password = find_field('gateway_incoming_auth_password')
        expect(incoming_auth_password).to be_present
        expect(incoming_auth_password.value).to be_present
        expect(incoming_auth_password.value).to match(/\A[a-zA-Z0-9]+\z/)
        expect(incoming_auth_password.value.length).to eq(20)
      end

      it 'should not autogenerate credential for :incoming_auth_username' do
        subject

        incoming_auth_username = find_field('gateway_incoming_auth_username')
        expect(incoming_auth_username).to be_present
        expect(incoming_auth_username.value).to be_empty
      end

      it 'should not autogenerate credential for :incoming_auth_password' do
        subject

        incoming_auth_password = find_field('gateway_incoming_auth_password')
        expect(incoming_auth_password).to be_present
        expect(incoming_auth_password.value).to be_empty
      end
    end

    context 'when credentials are present' do
      let(:gateway_attrs) { super().merge(incoming_auth_username: 'TestCredential', incoming_auth_password: 'TestCredential') }

      it 'should generate new credential by click on the link in hint for :incoming_auth_username with 20 chars' do
        subject

        click_link('Сlick to fill random username')
        incoming_auth_username = find_field('gateway_incoming_auth_username')
        expect(incoming_auth_username).to be_present
        expect(incoming_auth_username.value).to be_present
        expect(incoming_auth_username.value).to match(/\A[a-zA-Z0-9]+\z/)
        expect(incoming_auth_username.value.length).to eq(20)
        expect(incoming_auth_username.value).not_to eq('TestCredential')
      end

      it 'should generate new credential by click on the link in hint for :incoming_auth_password with 20 chars' do
        subject

        click_link('Сlick to fill random password')
        incoming_auth_password = find_field('gateway_incoming_auth_password')
        expect(incoming_auth_password).to be_present
        expect(incoming_auth_password.value).to be_present
        expect(incoming_auth_password.value).to match(/\A[a-zA-Z0-9]+\z/)
        expect(incoming_auth_password.value.length).to eq(20)
        expect(incoming_auth_password.value).not_to eq('TestCredential')
      end

      it 'should not autogenerate new credential for :incoming_auth_username' do
        subject

        incoming_auth_username = find_field('gateway_incoming_auth_username')
        expect(incoming_auth_username).to be_present
        expect(incoming_auth_username.value).to be_present
        expect(incoming_auth_username.value).to eq('TestCredential')
      end

      it 'should not autogenerate new credential for :incoming_auth_password' do
        subject

        incoming_auth_password = find_field('gateway_incoming_auth_password')
        expect(incoming_auth_password).to be_present
        expect(incoming_auth_password.value).to be_present
        expect(incoming_auth_password.value).to eq('TestCredential')
      end
    end
  end

  context 'when gateway is none external with credentials' do
    let(:gateway_traits) { super() + [:with_incoming_auth] }
    let(:gateway_attrs) do
      super().merge(incoming_auth_username: old_incoming_username, incoming_auth_password: old_incoming_password)
    end

    let(:old_incoming_username) { 'old_incoming_username' }
    let(:old_incoming_password) { 'old_incoming_password' }

    it 'should display credential fields' do
      subject

      switch_tab('Signaling')
      expect(page).to have_field('Incoming auth username', with: old_incoming_username)
      expect(page).to have_field('Incoming auth password', with: old_incoming_password)
    end
  end

  context 'when gateway is external' do
    let(:gateway_traits) { super() + [:with_incoming_auth] }
    let(:gateway_attrs) do
      super().merge(
        incoming_auth_username: old_incoming_username,
        incoming_auth_password: old_incoming_password,
        external_id: 9_999
      )
    end

    let(:old_incoming_username) { 'old_incoming_username' }
    let(:old_incoming_password) { 'old_incoming_password' }

    it 'should not display credential fields but not change value while update' do
      subject

      switch_tab('Signaling')
      expect(page).not_to have_field('Incoming auth username', with: old_incoming_username)
      expect(page).not_to have_field('Incoming auth password', with: old_incoming_password)

      click_on 'Update Gateway'
      expect(page).to have_flash_message('Gateway was successfully updated.', type: :notice)

      expect(gateway.reload).to have_attributes(
                                  incoming_auth_username: old_incoming_username,
                                  incoming_auth_password: old_incoming_password
                                )
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

        switch_tab('Signaling')
        expect(page).to have_field('Incoming auth username', with: old_incoming_username)
        expect(page).to have_field('Incoming auth password', with: old_incoming_password)
      end
    end
  end
end
