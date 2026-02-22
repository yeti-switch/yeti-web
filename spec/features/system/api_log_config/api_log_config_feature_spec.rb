# frozen_string_literal: true

RSpec.describe 'Index System Api Log Configs' do
  include_context :login_as_admin

  let(:record_attrs) { {} }
  let!(:record) { FactoryBot.create(:api_log_config, record_attrs) }

  describe 'index' do
    context 'when valid data' do
      let!(:second_record) { FactoryBot.create(:api_log_config, controller: 'API') }
      let(:record_attrs) { super().merge controller: 'APIController' }

      before { visit api_log_configs_path }

      it 'should render index page properly' do
        expect(page).to have_table_row(count: 2)
        expect(page).to have_table_cell(column: 'Controller', exact_text: 'API')
        expect(page).to have_table_cell(column: 'Controller', exact_text: 'APIController')
      end
    end
  end

  describe 'create' do
    subject { click_button 'Create Api log config' }

    context 'when valid data', :js do
      before do
        visit api_log_configs_path
        click_link 'New Api Log Config'
        fill_in_tom_select 'Controller', with: 'Api::Rest::Admin::AuthController'
      end

      it 'should create record' do
        subject

        expect(page).to have_flash_message 'Api log config was successfully created.'
        expect(System::ApiLogConfig.last!).to have_attributes(controller: 'Api::Rest::Admin::AuthController')
      end
    end
  end

  describe 'destroy' do
    subject { accept_confirm { within_table_row(id: record.id) { click_link 'Delete' } } }

    before { visit api_log_configs_path }

    it 'should destroy record', :js do
      subject

      expect(page).to have_flash_message 'Api log config was successfully destroyed.'
      expect { record.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end
end
