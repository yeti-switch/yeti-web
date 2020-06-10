# frozen_string_literal: true

RSpec.describe 'Create new Registration', type: :feature, js: true do
  subject do
    aa_form.submit
  end

  active_admin_form_for Equipment::Registration, 'new'
  include_context :login_as_admin

  before do
    visit new_equipment_registration_path

    aa_form.set_text 'Name', 'test'
    aa_form.set_text 'Domain', 'example.com'
    aa_form.set_text 'Username', 'rspec.test'
    aa_form.set_text 'Contact', 'sip:test'
  end

  it 'creates record' do
    subject
    record = Equipment::Registration.last
    expect(record).to be_present
    expect(record).to have_attributes(
      name: 'test',
      domain: 'example.com',
      username: 'rspec.test',
      contact: 'sip:test',
      pop_id: nil,
      node_id: nil,
      transport_protocol_id: Equipment::TransportProtocol.find_by!(name: 'UDP').id
    )
  end

  include_examples :changes_records_qty_of, Equipment::Registration, by: 1
  include_examples :shows_flash_message, :notice, 'Registration was successfully created.'
end
