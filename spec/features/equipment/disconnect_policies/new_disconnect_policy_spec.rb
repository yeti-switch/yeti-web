# frozen_string_literal: true

RSpec.describe 'Create new Disconnect Policy', type: :feature, js: true do
  subject do
    aa_form.submit
  end

  active_admin_form_for DisconnectPolicy, 'new'
  include_context :login_as_admin

  before do
    visit new_disconnect_policy_path

    aa_form.set_text 'Name', 'test'
  end

  it 'creates record' do
    subject
    record = DisconnectPolicy.last
    expect(record).to be_present
    expect(record).to have_attributes(name: 'test')
  end

  include_examples :changes_records_qty_of, DisconnectPolicy, by: 1
  include_examples :shows_flash_message, :notice, 'Disconnect policy was successfully created.'
end
