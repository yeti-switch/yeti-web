# frozen_string_literal: true

require 'spec_helper'

describe 'Create new Lnp Resolver', type: :feature, js: true do
  subject do
    aa_form.submit
  end

  active_admin_form_for System::LnpResolver, 'new'
  include_context :login_as_admin

  before do
    visit new_system_lnp_resolver_path

    aa_form.set_text 'Name', 'test'
    aa_form.set_text 'Address', 'example.com'
    aa_form.set_text 'Port', '1234'
  end

  it 'creates record' do
    subject
    record = System::LnpResolver.last
    expect(record).to be_present
    expect(record).to have_attributes(
      name: 'test',
      address: 'example.com',
      port: 1234
    )
  end

  include_examples :changes_records_qty_of, System::LnpResolver, by: 1
  include_examples :shows_flash_message, :notice, 'Lnp resolver was successfully created.'
end
