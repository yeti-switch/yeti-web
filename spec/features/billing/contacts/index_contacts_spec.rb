# frozen_string_literal: true

# test stub for determining n + 1
RSpec.describe 'Index Billing contacts', type: :feature, js: true do
  include_context :login_as_admin

  it 'visit all contacts' do
    contacts = create_list(:contact, 2, :filled)
    visit billing_contacts_path
    contacts.each do |contact|
      expect(page).to have_css('.resource_id_link', text: contact.id)
    end
  end
end
