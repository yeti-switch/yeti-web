# frozen_string_literal: true

RSpec.describe 'Index Log Api Logs', type: :feature do
  include_context :login_as_admin

  context 'when visit index page with two API Logs' do
    let!(:api_log_first) { FactoryBot.create(:api_log) }
    let!(:api_log_second) { FactoryBot.create(:api_log) }

    before { visit api_logs_path }

    it 'should render index page properly' do
      expect(page).to have_table_row count: 2
      expect(page).to have_table_cell column: 'Id', exact_text: api_log_first.id
      expect(page).to have_table_cell column: 'Id', exact_text: api_log_second.id
      expect(page).not_to have_link 'CSV'
    end
  end

  describe 'filter' do
    subject { click_button :Filter }

    let(:record_attrs) { {} }
    let!(:record) { FactoryBot.create(:api_log, record_attrs) }

    describe 'by Remote IP' do
      context 'when valid data' do
        let(:record_attrs) { super().merge remote_ip: '127.0.0.1' }

        before do
          visit api_logs_path
          fill_in 'Remote IP', with: '127.0.0.1'
        end

        it 'should render filtered records only' do
          subject

          expect(page).to have_table_row count: 1
          expect(page).to have_table_cell column: 'Id', exact_text: record.id
          expect(page).to have_field 'Remote IP', with: '127.0.0.1'
        end
      end
    end

    describe 'by Controller', :js do
      let(:record_attrs) { super().merge controller: 'Api::Rest::Admin::AuthController' }

      before do
        visit api_logs_path
        fill_in_chosen 'Controller', with: 'Api::Rest::Admin::AuthController'
      end

      it 'should return filtered records only' do
        subject

        expect(page).to have_table_row count: 1
        expect(page).to have_table_cell column: 'Id', exact_text: record.id
      end
    end
  end
end
