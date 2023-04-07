# frozen_string_literal: true

RSpec.describe 'Report Realtime Not Authenticated' do
  include_context :login_as_admin

  describe 'index' do
    context 'when valid data' do
      let!(:not_authenticated_cdr) { FactoryBot.create(:not_authenticated) }
      let!(:second_not_authenticated_cdr) { FactoryBot.create(:not_authenticated) }

      before { visit report_realtime_not_authenticateds_path }

      it 'should render index page properly' do
        expect(page).to have_page_title 'Report Realtime Not Authenticateds'
        expect(page).to have_table_row count: 2
        expect(page).to have_table_cell column: 'Auth Orig Ip', exact_text: not_authenticated_cdr.auth_orig_ip
        expect(page).to have_table_cell column: 'Auth Orig Ip', exact_text: second_not_authenticated_cdr.auth_orig_ip
        expect(page).to have_select 'Time Interval', selected: '1 Minute'
        expect(page).to have_flash_message 'Records for time interval 60 seconds are displayed by default'
      end
    end
  end
end
