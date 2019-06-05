# frozen_string_literal: true

require 'spec_helper'

describe 'Create new Radius Accounting Profile', type: :feature, js: true do
  subject do
    aa_form.submit
  end

  active_admin_form_for Equipment::Radius::AccountingProfile, 'new'
  include_context :login_as_admin

  before do
    visit new_equipment_radius_accounting_profile_path

    aa_form.set_text 'Name', 'test'
    aa_form.set_text 'Server', 'example.com'
    aa_form.set_text 'Port', '1234'
    aa_form.set_text 'Secret', 'thesecret'
  end

  it 'creates record' do
    subject
    record = Equipment::Radius::AccountingProfile.last
    expect(record).to be_present
    expect(record).to have_attributes(
      name: 'test',
      server: 'example.com',
      port: 1234,
      secret: 'thesecret',
      timeout: 100,
      attempts: 2,
      enable_start_accounting: false,
      enable_interim_accounting: false,
      interim_accounting_interval: 30,
      enable_stop_accounting: true
    )
  end

  include_examples :changes_records_qty_of, Equipment::Radius::AccountingProfile, by: 1
  include_examples :shows_flash_message, :notice, 'Accounting profile was successfully created.'
end
