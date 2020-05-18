# frozen_string_literal: true

require 'spec_helper'

describe 'Create new Billing Contact', type: :feature, js: true do
  subject do
    aa_form.submit
  end

  include_context :login_as_admin
  active_admin_form_for Billing::Contact, 'new'

  let!(:contractor) { FactoryBot.create(:customer) }

  before do
    visit new_billing_contact_path
    aa_form.select_chosen 'Contractor', contractor.name
    aa_form.select_chosen 'Admin user', admin_user.username
    aa_form.set_text 'Email', 'john.doe@example.com'
    aa_form.set_text 'Notes', 'test'
  end

  it 'creates correct billing account' do
    subject
    contact = Billing::Contact.last
    expect(contact).to be_present
    expect(contact).to have_attributes(
      contractor_id: contractor.id,
      admin_user_id: admin_user.id,
      email: 'john.doe@example.com',
      notes: 'test'
    )
  end

  include_examples :changes_records_qty_of, Billing::Contact, by: 1
  include_examples :shows_flash_message, :notice, 'Contact was successfully created.'
end
