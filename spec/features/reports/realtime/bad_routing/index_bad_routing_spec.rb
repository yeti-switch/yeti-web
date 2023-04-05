# frozen_string_literal: true

RSpec.describe 'Report Realtime Bad Routing' do
  include_context :login_as_admin

  describe 'index' do
    context 'when valid data' do
      let!(:bad_routing) { FactoryBot.create(:bad_routing) }
      let!(:second_bad_routing) { FactoryBot.create(:bad_routing) }

      before { visit report_realtime_bad_routings_path }

      it 'should render index page properly' do
        expect(page).to have_page_title 'Report Realtime Bad Routings'
        expect(page).to have_table_row count: 2
        expect(page).to have_table_cell column: 'Customer Auth', exact_text: bad_routing.customer_auth.display_name
        expect(page).to have_table_cell column: 'Customer Auth', exact_text: second_bad_routing.customer_auth.display_name
        expect(page).to have_flash_message 'Records for time interval 60 seconds are displayed by default'
      end
    end
  end
end
