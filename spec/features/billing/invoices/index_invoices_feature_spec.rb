# frozen_string_literal: true

RSpec.describe 'Index Invoices', type: :feature do
  include_context :login_as_admin
  let!(:invoices) { FactoryBot.create_list(:invoice, 2, :manual, :pending, :with_vendor_account) }

  it 'n+1 checks' do
    visit invoices_path
    invoices.each do |invoice|
      expect(page).to have_css('.resource_id_link', text: invoice.id)
    end
  end
end
