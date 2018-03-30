require 'spec_helper'

describe 'CDR exports', type: :feature do
  include_context :login_as_admin

  describe 'index' do
    let!(:cdr_export) do
      create(:cdr_export, :completed)
    end

    before do
      visit cdr_exports_path
    end

    it 'cdr export should be displayed' do
      within "#cdr_export_base_#{cdr_export.id}" do
        expect(page).to have_selector('.col-id a', text: cdr_export.id)
        expect(page).to have_selector('.col-download a', 'Download')
        expect(page).to have_selector('.col-status', text: cdr_export.status)
        expect(page).to have_selector('.col-fields', text: cdr_export.fields.join(', '))
        expect(page).to have_selector('.col-filters', text: cdr_export.filters)
        expect(page).to have_selector('.col-callback_url', text: cdr_export.callback_url)
        expect(page).to have_selector('.col-created_at', text: cdr_export.created_at.to_s(:db))
      end
    end
  end

  describe 'new', js: true do
    let!(:account) do
      create(:account, name: 'rspec')
    end
    before do
      Capybara.default_driver = :poltergeist
      visit new_cdr_export_path
    end
    after do
      Capybara.default_driver = :rack_test
    end

    before do
      within '#new_cdr_export' do
        chosen_select('#cdr_export_fields_input .search-field input', search: 'success', multiple: true)
        chosen_select('#cdr_export_fields_input .search-field input', search: 'id', multiple: true)
        page.find('#cdr_export_time_start_gteq').set('2018-01-01')
        page.find('#cdr_export_time_start_lteq').set('2018-03-01')
        within '#cdr_export_customer_acc_id_eq_input' do
          chosen_select('.chosen-single', search: "#{account.name} | #{account.id}")
        end
        page.click_button 'Create Cdr export'
      end
    end

    it 'cdr export should be created' do
      cdr_export = CdrExport.last!
      expect(page).to have_current_path(cdr_export_path(cdr_export))
      expect(page).to have_text('Cdr export was successfully created.')
      expect(cdr_export).to have_attributes(
        callback_url: nil,
        fields: ['id', 'success'],
        filters: {
          'time_start_gteq' => '2018-01-01',
          'time_start_lteq' => '2018-03-01',
          'is_last_cdr_eq' => false,
          'customer_acc_id_eq' => account.id.to_s
        },
        status: 'Pending'
      )
    end
  end
end
