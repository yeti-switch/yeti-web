# frozen_string_literal: true

RSpec.describe 'Report Realtime Origination Performance', type: :feature do
  include_context :login_as_admin

  describe 'index' do
    context 'when valid data' do
      let!(:customers_auth) { FactoryBot.create(:customers_auth) }
      let!(:second_customers_auth) { FactoryBot.create(:customers_auth) }

      before do
        FactoryBot.create_list(:cdr, 5, customer_auth: customers_auth, time_start: 28.hours.ago.utc)
        FactoryBot.create(:cdr, customer_auth: second_customers_auth, time_start: 28.hours.ago.utc)
        visit report_realtime_origination_performances_path(q: { time_interval_eq: 1.day })
      end

      it 'should render index page properly' do
        expect(page).to have_page_title 'Report Realtime Origination Performances'
        expect(page).to have_table_row count: 2
        expect(page).to have_table_cell column: 'Customer Auth', exact_text: customers_auth.display_name
        expect(page).to have_table_cell column: 'Customer Auth', exact_text: second_customers_auth.display_name
        expect(page).to have_select 'Time Interval', selected: '1 Day'
        expect(page).to_not have_css('flash-warning')
        expect(page).to_not have_css('flash-error')
      end
    end
  end
end
