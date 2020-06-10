# frozen_string_literal: true

RSpec.describe 'Create new CDR export', js: true do
  include_context :login_as_admin

  let!(:account) do
    create(:account, name: 'rspec')
  end

  context 'with all filled attributes' do
    before do
      visit new_cdr_export_path
      within '#new_cdr_export' do
        chosen_select('#cdr_export_fields_input .search-field input', search: 'success', multiple: true)
        chosen_select('#cdr_export_fields_input .search-field input', search: 'id', multiple: true)
        within '#cdr_export_filters_customer_acc_id_eq_input' do
          chosen_select('.chosen-single', search: "#{account.name} | #{account.id}")
        end
        page.find('#cdr_export_filters_time_start_gteq').set('2018-01-01')
        page.find('#cdr_export_filters_time_start_lteq').set('2018-03-01')
        page.click_button 'Create Cdr export'
      end
    end

    it 'cdr export should be created' do
      cdr_export = CdrExport.last!
      expect(page).to have_current_path(cdr_export_path(cdr_export))
      expect(page).to have_text('Cdr export was successfully created.')
      expect(cdr_export).to have_attributes(
        callback_url: nil,
        fields: %w[id success],
        status: 'Pending',
        filters: CdrExport::FiltersModel.new(
          'time_start_gteq' => '2018-01-01',
          'time_start_lteq' => '2018-03-01',
          'customer_acc_id_eq' => account.id.to_s
        )
      )
    end
  end

  context 'with inherited fields' do
    before do
      create :cdr_export, :completed, fields: %w[id success customer_id]
      visit new_cdr_export_path
      within '#new_cdr_export' do
        within '#cdr_export_filters_customer_acc_id_eq_input' do
          chosen_select('.chosen-single', search: "#{account.name} | #{account.id}")
        end
        page.find('#cdr_export_filters_time_start_gteq').set('2018-01-01')
        page.find('#cdr_export_filters_time_start_lteq').set('2018-03-01')
        page.click_button 'Create Cdr export'
      end
    end

    it 'cdr export should be created' do
      cdr_export = CdrExport.last!
      expect(page).to have_current_path(cdr_export_path(cdr_export))
      expect(page).to have_text('Cdr export was successfully created.')
      expect(cdr_export).to have_attributes(
        callback_url: nil,
        fields: %w[id customer_id success],
        status: 'Pending',
        filters: CdrExport::FiltersModel.new(
          'time_start_gteq' => '2018-01-01',
          'time_start_lteq' => '2018-03-01',
          'customer_acc_id_eq' => account.id.to_s
        )
      )
    end
  end
end
