# frozen_string_literal: true

RSpec.describe 'Equipment Registrations show', js: true do
  subject do
    visit equipment_registration_path(registration.id)
  end

  include_context :login_as_admin
  let!(:registration) { create(:registration, :filled) }

  it 'shows details' do
    subject

    expect(page).to have_attribute_row('ID', exact_text: registration.id)
    expect(page).to have_attribute_row('SIP INTERFACE NAME', exact_text: registration.sip_interface_name)
  end
end
