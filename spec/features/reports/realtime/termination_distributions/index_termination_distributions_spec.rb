# frozen_string_literal: true

RSpec.describe 'Report Realtime Termination Distribution', type: :feature do
  include_context :login_as_admin

  describe 'index' do
    context 'when valid data' do
      let!(:vendor) { FactoryBot.create(:vendor) }
      let!(:second_vendor) { FactoryBot.create(:vendor) }

      before do
        FactoryBot.create_list(:cdr, 5, vendor: vendor)
        FactoryBot.create(:cdr, vendor: second_vendor)
        visit report_realtime_termination_distributions_path(q: { time_interval_eq: 1.day })
      end

      it 'should render index page properly' do
        expect(page).to have_page_title 'Report Realtime Termination Distributions'
        expect(page).to have_table_row count: 2
        expect(page).to have_table_cell column: 'Vendor', exact_text: vendor.display_name
        expect(page).to have_table_cell column: 'Vendor', exact_text: second_vendor.display_name
        expect(page).to have_select 'Time Interval', selected: '1 Day'
        expect(page).to_not have_css('flash-warning')
        expect(page).to_not have_css('flash-error')
      end
    end
  end
end
