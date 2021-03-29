# frozen_string_literal: true

RSpec.describe 'Equipment Registrations new', js: true do
  subject do
    visit new_equipment_registration_path
    fill_form!
    click_submit('Create Registration')
  end

  include_context :login_as_admin

  context 'without filled inputs' do
    let(:fill_form!) { nil }

    it 'does not create an registration' do
      expect {
        subject
        expect(page).to have_semantic_errors(count: 4)
      }.to_not change { Equipment::Registration.count }

      expect(page).to have_semantic_error("Name can't be blank")
      expect(page).to have_semantic_error("Domain can't be blank")
      expect(page).to have_semantic_error('Contact is invalid')
      expect(page).to have_semantic_error("Username can't be blank")
    end
  end

  let(:fill_form!) do
    within_form_for do
      fill_in 'Name*', with: 'Registration test', exact: true
      fill_in 'Domain', with: 'reg.example.com'
      fill_in 'Contact', with: 'sip:test.reg.com'
      fill_in 'Username', with: 'test.reg'
    end
  end

  context 'when fill required fields' do
    it 'creates registration' do
      expect {
        subject
        expect(page).to have_flash_message('Registration was successfully created.', type: :notice)
      }.to change { Equipment::Registration.count }.by(1)
      registration = Equipment::Registration.last!
      expect(registration).to have_attributes(
                                name: 'Registration test',
                                domain: 'reg.example.com',
                                contact: 'sip:test.reg.com',
                                username: 'test.reg',
                                sip_interface_name: '',
                                pop: nil,
                                node: nil,
                                transport_protocol: Equipment::TransportProtocol.find_by!(name: 'UDP'),
                                sip_schema: System::SipSchema.find_by!(name: 'sip')
                              )
    end
  end

  context 'when fill sip_interface_name too' do
    let(:fill_form!) do
      super()
      within_form_for do
        fill_in 'SIP Interface Name', with: 'sip.test'
      end
    end

    it 'creates registration' do
      expect {
        subject
        expect(page).to have_flash_message('Registration was successfully created.', type: :notice)
      }.to change { Equipment::Registration.count }.by(1)
      registration = Equipment::Registration.last!
      expect(registration).to have_attributes(
                                name: 'Registration test',
                                domain: 'reg.example.com',
                                contact: 'sip:test.reg.com',
                                username: 'test.reg',
                                sip_interface_name: 'sip.test'
                              )
    end
  end
end
