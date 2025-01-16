# frozen_string_literal: true

RSpec.describe 'Create new Network Type', type: :feature, js: true do
  active_admin_form_for System::NetworkType, 'new'
  include_context :login_as_admin

  subject do
    visit new_system_network_type_path

    aa_form.set_text('Name', 'test')
    aa_form.set_text('Sorting priority', '30')

    aa_form.submit
  end

  it 'creates record' do
    subject

    record = System::NetworkType.last
    expect(record).to be_present
    expect(record).to have_attributes(name: 'test', sorting_priority: 30)
  end

  include_examples :changes_records_qty_of, System::NetworkType, by: 1
  include_examples :shows_flash_message, :notice, 'Network type was successfully created.'
end
