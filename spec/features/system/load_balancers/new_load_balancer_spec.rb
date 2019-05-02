# frozen_string_literal: true

require 'spec_helper'

describe 'Create new Load Balancer', type: :feature, js: true do
  subject do
    aa_form.submit
  end

  active_admin_form_for System::LoadBalancer, 'new'
  include_context :login_as_admin

  before do
    visit new_system_load_balancer_path

    aa_form.set_text 'Name', 'test'
    aa_form.set_text 'Signalling ip', '192.168.100.5'
  end

  it 'creates record' do
    subject
    record = System::LoadBalancer.last
    expect(record).to be_present
    expect(record).to have_attributes(
      name: 'test',
      signalling_ip: '192.168.100.5'
    )
  end

  include_examples :changes_records_qty_of, System::LoadBalancer, by: 1
  include_examples :shows_flash_message, :notice, 'Load balancer was successfully created.'
end
