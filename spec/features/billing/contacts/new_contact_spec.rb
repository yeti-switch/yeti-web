# frozen_string_literal: true

RSpec.describe 'Create new Billing Contact', type: :feature, js: true do
  subject do
    click_submit('Create Contact')
  end

  include_context :login_as_admin

  let!(:contractor) { FactoryBot.create(:customer) }

  before do
    visit new_billing_contact_path
    fill_in_chosen 'Contractor', with: contractor.name, ajax: true
    fill_in_chosen 'Admin user', with: admin_user.username
    fill_in 'Email',  with: 'john.doe@example.com'
    fill_in 'Notes',  with: 'test'
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
