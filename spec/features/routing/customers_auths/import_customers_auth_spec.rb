# frozen_string_literal: true

RSpec.describe 'Export Customers Auth' do
  include_context :login_as_admin

  context 'when there is already exist session of Import' do
    let(:record_attrs) { {} }
    let!(:record) { FactoryBot.create(:importing_customers_auth, record_attrs) }
    let(:privacy_mode_name) { CustomersAuth::PRIVACY_MODES[record.privacy_mode_id] }

    before do
      visit customers_auths_path
      click_action_item 'Import Customers Auths'
    end

    it 'should render index page of "Import session"' do
      expect(page).to have_flash_message 'Please finish your previous import session.'
      expect(page).to have_action_item 'Create new ones'
      expect(page).to have_action_item 'Create and update'
      expect(page).to have_action_item 'Only update'
      expect(page).to have_action_item 'Cancel import session'
      expect(page).to have_action_item 'Apply unique columns'

      expect(page).to have_table_row count: 1
      expect(page).to have_table_cell column: 'privacy_mode_id', exact_text: privacy_mode_name
    end

    it 'should cancel current Import session' do
      expect { click_action_item 'Cancel import session' }.to change(Importing::CustomersAuth, :count)
      expect(page).to have_current_path customers_auths_path
    end
  end

  context 'when create the new Import session' do
    subject { click_action_item 'Import Customers Auths' }

    before { visit customers_auths_path }

    it 'should render Import form' do
      subject

      expect(page).to have_current_path import_customers_auths_path
      expect(page).to have_field 'Col sep'
      expect(page).to have_field 'Row sep'
      expect(page).to have_field 'Quote char'
      expect(page).to have_select 'Script'
      expect(page).to have_field 'File', type: :file
      expect(page).to have_field count: 5
      expect(page).to have_button 'Import'
    end
  end
end
