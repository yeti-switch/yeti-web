# frozen_string_literal: true

RSpec.describe 'Index Log Api Logs', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    api_logs = create_list(:api_log, 2)
    visit api_logs_path
    api_logs.each do |api_log|
      expect(page).to have_css('.resource_id_link', text: api_log.id)
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
