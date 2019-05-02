# frozen_string_literal: true

require 'spec_helper'

describe 'Create new Radius Auth Profile', type: :feature, js: true do
  subject do
    aa_form.submit
  end

  active_admin_form_for Equipment::Radius::AuthProfile, 'new'
  include_context :login_as_admin

  before do
    visit new_equipment_radius_auth_profile_path

    aa_form.set_text 'Name', 'test'
    aa_form.set_text 'Server', 'example.com'
    aa_form.set_text 'Port', '1234'
    aa_form.set_text 'Secret', 'thesecret'
  end

  it 'creates record' do
    subject
    record = Equipment::Radius::AuthProfile.last
    expect(record).to be_present
    expect(record).to have_attributes(
      name: 'test',
      server: 'example.com',
      port: 1234,
      secret: 'thesecret',
      reject_on_error: true,
      timeout: 100,
      attempts: 2
    )
  end

  include_examples :changes_records_qty_of, Equipment::Radius::AuthProfile, by: 1
  include_examples :shows_flash_message, :notice, 'Auth profile was successfully created.'
end
