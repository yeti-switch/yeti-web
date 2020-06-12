# frozen_string_literal: true

RSpec.describe 'Create Import Contractors', type: :feature, js: true do
  subject do
    within('form') { click_button 'Import' }
    expect(page).to have_current_path(importing_contractors_path)
  end

  include_context :login_as_admin
  let!(:smtp_connection) { create(:smtp_connection, name: 'test_smtp_conn') }
  before { create_list(:vendor, 2, smtp_connection: smtp_connection) }

  before do
    visit contractors_path
    within('#titlebar_right') { click_link 'Import Contractors' }
    expect(page).to have_current_path(import_contractors_path)
    attach_file 'File', Rails.root.join('spec/fixtures/files/import_contractors.csv')
  end

  it 'creates import' do
    subject

    within('.index_content') do
      expect(page).to have_selector('table tbody tr', count: 2)
      expect(page).to have_selector('table tbody tr td.col-o_id', exact_text: '', count: 2)
      expect(page).to have_selector('table tbody tr td.col-is_changed', exact_text: '', count: 2)
    end
  end

  it 'creates correct import records', :aggregate_failures do
    expect { subject }.to change { Importing::Contractor.count }.by(2)

    import_accounts = Importing::Contractor.last(2)

    # see spec/fixtures/files/import_contractors.csv
    expect(import_accounts.first).to have_attributes(
      o_id: nil,
      is_changed: nil,
      name: 'contractor2',
      enabled: true,
      vendor: true,
      customer: false,
      smtp_connection_name: smtp_connection.name,
      smtp_connection_id: smtp_connection.id
    )

    expect(import_accounts.second).to have_attributes(
      o_id: nil,
      is_changed: nil,
      name: 'contractor1',
      enabled: true,
      vendor: false,
      customer: true,
      smtp_connection_name: '',
      smtp_connection_id: nil
    )
  end
end
