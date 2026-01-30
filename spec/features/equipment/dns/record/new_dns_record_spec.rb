# frozen_string_literal: true

RSpec.describe 'Create new Dns Record', type: :feature, js: true do
  subject do
    aa_form.submit
  end

  active_admin_form_for Equipment::Dns::Record, 'new'
  include_context :login_as_admin
  let!(:zone) { FactoryBot.create(:dns_zone) }

  before do
    visit new_equipment_dns_record_path

    aa_form.set_text 'Name', 'test'
    aa_form.fill_in_tom_select 'Zone', with: zone.name
    aa_form.set_text 'Content', 'record content'
  end

  it 'creates record' do
    subject
    record = Equipment::Dns::Record.last
    expect(record).to be_present
    expect(record).to have_attributes(name: 'test')
  end

  include_examples :changes_records_qty_of, Equipment::Dns::Record, by: 1
  include_examples :shows_flash_message, :notice, 'Record was successfully created.'
end
