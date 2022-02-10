# frozen_string_literal: true

RSpec.describe 'Index Routing Plans', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    routing_plans = create_list(:routing_plan, 2, :filled)
    visit routing_routing_plans_path
    routing_plans.each do |routing_plan|
      expect(page).to have_css('.resource_id_link', text: routing_plan.id)
    end
  end

  describe 'account filter', js: true do
    let!(:customer_auth_1) { FactoryBot.create(:customers_auth, account: account_1, routing_plan: routing_plan_1) }
    let!(:contractor_1) { FactoryBot.create(:customer) }
    let!(:account_1) { FactoryBot.create(:account, contractor: contractor_1) }
    let!(:routing_plan_1) { FactoryBot.create(:routing_plan) }

    let!(:customer_auth_2) { FactoryBot.create(:customers_auth, :filled, account: account_2, routing_plan: routing_plan_2) }
    let!(:contractor_2) { FactoryBot.create(:vendor) }
    let!(:account_2) { FactoryBot.create(:account, contractor: contractor_2) }
    let!(:routing_plan_2) { FactoryBot.create(:routing_plan) }

    subject do
      visit routing_routing_plans_path
      within_filters do
        fill_in_chosen 'Assigned to account', with: account_1.display_name, exact: true, ajax: true
      end
      click_on 'Filter'
    end

    it 'should be filtered by account' do
      subject

      within_filters do
        expect(page).to have_field_chosen('Assigned to account', with: account_1.display_name)
      end
      expect(page).to have_table_row(count: 1)
      expect(page).to have_table_cell(text: routing_plan_1.id.to_s, column: 'ID', exact: true)
    end
  end
end
