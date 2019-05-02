# frozen_string_literal: true

require 'spec_helper'

describe 'Create new Network Prefix', type: :feature, js: true do
  subject do
    aa_form.submit
  end

  active_admin_form_for System::NetworkPrefix, 'new'
  include_context :login_as_admin

  let!(:network) { FactoryGirl.create(:network, name: 'some network') }
  before do
    FactoryGirl.create(:network)

    visit new_system_network_prefix_path

    aa_form.set_text 'Prefix', '123'
    aa_form.select_chosen 'Network', network.display_name
  end

  it 'creates record' do
    subject
    record = System::NetworkPrefix.last
    expect(record).to be_present
    expect(record).to have_attributes(
      prefix: '123',
      network_id: network.id
    )
  end

  include_examples :changes_records_qty_of, System::NetworkPrefix, by: 1
  include_examples :shows_flash_message, :notice, 'Network prefix was successfully created.'
end
