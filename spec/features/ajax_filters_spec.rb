# frozen_string_literal: true

RSpec.describe 'Load filter options', type: :feature, js: true do
  include_context :login_as_admin

  context 'customer filter' do
    subject do
      visit cdrs_path

      # fill_in_tom_select('Customer', search: 'cus', with: match_customers.first.name)
    end

    let!(:match_customers) {
      [
        FactoryBot.create(:customer, name: 'customer_1'),
        FactoryBot.create(:customer, name: 'customer_2')
      ]
    }
    let!(:other_customer) { FactoryBot.create(:customer, name: 'other') }

    it 'when type letters load options (2 results)' do
      subject
      customer = match_customers.first

      parent = find('.filter_form')
      customer_filter = Section::TomSelect.by_label('CUSTOMER', exact: true, parent:)
      customer_filter.control.click # open dropdown
      customer_filter.dropdown.search('cus')

      # correct customers loaded
      expect(customer_filter).to have_options_texts match_customers.map(&:display_name)

      # filtered correctly
      customer_filter.dropdown.select_option(customer.display_name)
      page.find('.filter_form input[type=submit]').click

      expect(CGI.unescape(page.current_url)).to include("q[customer_id_eq]=#{customer.id}")
      # expect(page).to have_field_tom_select('Customer', with: customer.display_name)
      parent = find('.filter_form')
      new_customer_filter = Section::TomSelect.by_label('CUSTOMER', exact: true, parent:)
      expect(new_customer_filter).to have_selected_text customer.display_name
    end
  end
end
