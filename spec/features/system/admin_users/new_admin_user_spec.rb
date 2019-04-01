# frozen_string_literal: true

require 'spec_helper'

describe 'Create new Admin User', type: :feature, js: true do
  subject do
    aa_form.submit
  end

  active_admin_form_for AdminUser, 'new'
  include_context :login_as_admin do
    let(:admin_user) { FactoryGirl.create(:admin_user, roles: ['root']) }
  end

  before do
    visit new_admin_user_path

    aa_form.set_text 'Email', 'test@example.com'
    aa_form.set_text 'Password', 'thepassword', exact_field: true
    aa_form.set_text 'Password confirmation', 'thepassword'
    aa_form.select_value 'Roles', 'user'
  end

  it 'creates record' do
    subject
    record = AdminUser.last
    expect(record).to be_present
    expect(record).to have_attributes(
      email: 'test@example.com',
      encrypted_password: be_present,
      roles: ['user']
    )
  end

  include_examples :changes_records_qty_of, AdminUser, by: 1
  include_examples :shows_flash_message, :notice, 'Admin user was successfully created.'
end
