# frozen_string_literal: true

RSpec.describe 'Equipment Registrations index' do
  subject do
    visit equipment_registrations_path
    filter_records!
  end

  include_context :login_as_admin
  let(:filter_records!) { nil }
  let!(:registrations) do
    create_list(:registration, 2, :filled)
  end

  it 'shows table' do
    subject

    expect(page).to have_table_row(count: registrations.size)
    registrations.each do |registration|
      expect(page).to have_table_cell column: 'ID', text: registration.id
      expect(page).to have_table_cell column: 'SIP Interface Name', text: registration.sip_interface_name
    end
  end

  context 'when filter by sip_interface_name' do
    let(:target_registration) { registrations.first }

    let(:filter_records!) do
      within_filters do
        fill_in 'SIP Interface Name', with: target_registration.sip_interface_name
      end
      click_submit('Filter')
    end

    it 'shows table' do
      subject

      within_filters do
        expect(page).to have_field 'SIP Interface Name', with: target_registration.sip_interface_name
      end
      expect(page).to have_table_row(count: 1)
      expect(page).to have_table_cell column: 'ID', text: target_registration.id
      expect(page).to have_table_cell column: 'SIP Interface Name', text: target_registration.sip_interface_name
    end
  end
end
