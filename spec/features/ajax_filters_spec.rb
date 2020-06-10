# frozen_string_literal: true

RSpec.describe 'Load filter options', type: :feature, js: true do
  include_context :login_as_admin
  before { visit cdrs_path }
  context 'customer filter' do
    let!(:goal_customer_list) {
      [
        FactoryBot.create(:customer, name: 'customer_1'),
        FactoryBot.create(:customer, name: 'customer_2')
      ]
    }
    let!(:other_customer) { FactoryBot.create(:customer, name: 'other') }

    subject do
      # open chosen popup to get input
      find('#q_customer_id_chosen').click
      find('#q_customer_id_chosen input').fill_in with: 'cus'
    end

    it 'should have one option in select' do
      within '#sidebar #new_q #q_customer_input select', visible: false do
        expect(page).to have_css('option', count: 1, visible: false)
        expect(page).to have_css('option:first-child', text: 'Any', visible: false)
      end
    end

    it 'when type letters load options (2 results and "Any" existed)' do
      subject
      goal_customer_list.each do |item|
        expect(page).to have_css('#q_customer_input select option', text: item.name, visible: false)
      end
      # 2 results from database and "Any" option by default = total 3
      expect(page).to have_css('#q_customer_input select option', count: 3, visible: false)
    end

    it 'should select option and execute filter ' do
      customer = goal_customer_list.first
      subject
      # make first element selected
      find('#q_customer_id_chosen li', text: customer.name).click

      # execute filter and reload page
      page.find('input[type=submit]').click

      expect(CGI.unescape(page.current_url)).to include("q[customer_id_eq]=#{customer.id}")
      # check selected element
      expect(find('#q_customer_input select option', visible: false, text: customer.name)).to be_selected
    end
  end
end
