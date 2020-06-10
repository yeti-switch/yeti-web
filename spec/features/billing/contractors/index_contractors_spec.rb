# frozen_string_literal: true

RSpec.describe 'Index Contractors', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    vendors = create_list(:vendor, 2)
    visit contractors_path
    vendors.each do |vendor|
      expect(page).to have_css('.resource_id_link', text: vendor.id)
    end
  end
end
