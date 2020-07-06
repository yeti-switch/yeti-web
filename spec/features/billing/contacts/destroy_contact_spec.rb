# frozen_string_literal: true

RSpec.describe Billing::Contact, :js do
  include_context :login_as_admin
  let!(:customer) { FactoryBot.create :customer }
  let!(:contact) { FactoryBot.create :contact }
  let!(:customer_traffic_scheduler) { create :customer_traffic_scheduler, customer: customer }

  before { visit billing_contacts_path(id: contact.id) }
  subject { click_link 'Delete Billing Contact' }

  it 'should destroy' do
    subject
    expect(page).to have_selector '.flash', text: 'Contact was successfully destroyed.'
  end
end
