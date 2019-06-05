# frozen_string_literal: true

require 'spec_helper'

describe 'Create new Smtp Connection', type: :feature, js: true do
  subject do
    aa_form.submit
  end

  active_admin_form_for System::SmtpConnection, 'new'
  include_context :login_as_admin

  before do
    visit new_system_smtp_connection_path

    aa_form.set_text 'Name', 'test'
    aa_form.set_text 'Host', 'test.example.com'
    aa_form.set_text 'From address', 'rspec@example.com'
  end

  it 'creates record' do
    subject
    record = System::SmtpConnection.last
    expect(record).to be_present
    expect(record).to have_attributes(
      name: 'test',
      host: 'test.example.com',
      from_address: 'rspec@example.com',
      auth_user: '',
      auth_password: '',
      global: true
    )
  end

  include_examples :changes_records_qty_of, System::SmtpConnection, by: 1
  include_examples :shows_flash_message, :notice, 'Smtp connection was successfully created.'
end
