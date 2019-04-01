# frozen_string_literal: true

require 'spec_helper'

describe 'Create new Network', type: :feature, js: true do
  subject do
    aa_form.submit
  end

  active_admin_form_for System::Network, 'new'
  include_context :login_as_admin

  before do
    visit new_system_network_path

    aa_form.set_text 'Name', 'test'
  end

  it 'creates record' do
    subject
    record = System::Network.last
    expect(record).to be_present
    expect(record).to have_attributes(name: 'test')
  end

  include_examples :changes_records_qty_of, System::Network, by: 1
  include_examples :shows_flash_message, :notice, 'Network was successfully created.'
end
