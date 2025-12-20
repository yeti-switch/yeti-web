# frozen_string_literal: true

RSpec.describe 'Apply Unique Columns Import Contractors', type: :feature, js: true do
  subject do
    within('#titlebar_right') { click_link 'Apply unique columns' }
    within('.ui-dialog') do
      click_button 'OK'
    end
    expect(page).to have_current_path(importing_contractors_path)
  end

  include_context :login_as_admin
  let!(:smtp_connection) { create(:smtp_connection, name: 'test_smtp_conn') }
  before { create_list(:vendor, 2) }

  let!(:import_contractor_1) do
    create :importing_contractor,
           name: 'c1',
           customer: true,
           smtp_connection: smtp_connection,
           smtp_connection_name: smtp_connection.name
  end
  let!(:import_contractor_2) {
    create(:importing_contractor, name: 'c2', vendor: true, smtp_connection_name: '')
  }

  before do
    visit contractors_path
    within('#titlebar_right') { click_link 'Import Contractors' }
    expect(page).to have_current_path(importing_contractors_path)
    expect(page).to have_selector('.flashes .flash.flash_notice', text: 'Please finish your previous import session.')
  end

  it 'changes import' do
    subject
    expect(page).to have_selector('.flashes .flash.flash_notice', text: 'Unique columns applied!')

    within('.index_content') do
      expect(page).to have_selector('table tbody tr', count: 2)
      expect(page).to have_selector('table tbody tr td.col-o_id', exact_text: '', count: 2)
      expect(page).to have_selector('table tbody tr td.col-is_changed', exact_text: 'YES', count: 2)
    end
  end

  it 'updates import contractors', :aggregate_failures do
    subject

    expect(import_contractor_1.reload).to have_attributes(
      o_id: nil,
      is_changed: true
    )

    expect(import_contractor_2.reload).to have_attributes(
      o_id: nil,
      is_changed: true
    )
  end

  context 'when matched to existing records and changed' do
    let!(:contractor_1) { create(:customer, name: import_contractor_1.name, smtp_connection: nil) }
    let!(:contractor_2) { create(:vendor, name: import_contractor_2.name, smtp_connection: nil, enabled: false) }

    it 'changes import' do
      subject
      expect(page).to have_selector('.flashes .flash.flash_notice', text: 'Unique columns applied!')

      within('.index_content') do
        expect(page).to have_selector('table tbody tr', count: 2)
        expect(page).to have_selector('table tbody tr td.col-o_id', exact_text: contractor_1.id.to_s, count: 1)
        expect(page).to have_selector('table tbody tr td.col-o_id', exact_text: contractor_2.id.to_s, count: 1)
        expect(page).to have_selector('table tbody tr td.col-is_changed', exact_text: 'YES', count: 2)
      end
    end

    it 'updates import contractors', :aggregate_failures do
      subject

      expect(import_contractor_1.reload).to have_attributes(
        o_id: contractor_1.id,
        is_changed: true
      )

      expect(import_contractor_2.reload).to have_attributes(
        o_id: contractor_2.id,
        is_changed: true
      )
    end
  end

  context 'when matched to existing records but not changed' do
    let!(:contractor_1) { create(:customer, name: import_contractor_1.name, smtp_connection: smtp_connection) }
    let!(:contractor_2) { create(:vendor, name: import_contractor_2.name, smtp_connection_id: nil) }

    it 'changes import' do
      subject
      expect(page).to have_selector('.flashes .flash.flash_notice', text: 'Unique columns applied!')

      within('.index_content') do
        expect(page).to have_selector('table tbody tr', count: 2)
        expect(page).to have_selector('table tbody tr td.col-o_id', exact_text: contractor_1.id.to_s, count: 1)
        expect(page).to have_selector('table tbody tr td.col-o_id', exact_text: contractor_2.id.to_s, count: 1)
        expect(page).to have_selector('table tbody tr td.col-is_changed', exact_text: 'NO', count: 2)
      end
    end

    it 'updates import contractors', :aggregate_failures do
      subject

      expect(import_contractor_1.reload).to have_attributes(
        o_id: contractor_1.id,
        is_changed: false
      )

      expect(import_contractor_2.reload).to have_attributes(
        o_id: contractor_2.id,
        is_changed: false
      )
    end
  end
end
