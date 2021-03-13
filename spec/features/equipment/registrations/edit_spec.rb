# frozen_string_literal: true

RSpec.describe 'Equipment Registrations edit', js: true do
  subject do
    visit edit_equipment_registration_path(registration.id)
    fill_form!
    click_submit('Update Registration')
  end

  include_context :login_as_admin
  let!(:registration) { create(:registration, :filled) }

  context 'when change sip_interface_name' do
    let(:fill_form!) do
      within_form_for do
        fill_in 'SIP Interface Name', with: 'sip.test'
      end
    end

    it 'updates registration' do
      subject
      expect(page).to have_flash_message('Registration was successfully updated.', type: :notice)
      expect(registration.reload).to have_attributes(
                                sip_interface_name: 'sip.test'
                              )
    end
  end
end
