# frozen_string_literal: true

RSpec.describe 'Create new Dns Zone', type: :feature, js: true do
  subject do
    aa_form.submit
  end

  active_admin_form_for Equipment::Dns::Zone, 'new'
  include_context :login_as_admin

  before do
    visit new_equipment_dns_zone_path

    aa_form.set_text 'Name', 'test'
    aa_form.set_text 'Soa rname', 'test'
    aa_form.set_text 'Soa mname', 'test'
  end

  it 'creates record' do
    subject
    record = Equipment::Dns::Zone.last
    expect(record).to be_present
    expect(record).to have_attributes(name: 'test')
  end

  include_examples :changes_records_qty_of, Equipment::Dns::Zone, by: 1
  include_examples :shows_flash_message, :notice, 'Zone was successfully created.'
end
