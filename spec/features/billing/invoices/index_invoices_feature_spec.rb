# frozen_string_literal: true

RSpec.describe 'Index Invoices', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    invoices = create_list(:invoice, 2, :manual, :filled)
    visit invoices_path
    invoices.each do |invoice|
      expect(page).to have_css('.resource_id_link', text: invoice.id)
    end
  end
end
