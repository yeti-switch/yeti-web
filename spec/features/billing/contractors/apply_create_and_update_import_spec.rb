# frozen_string_literal: true

RSpec.describe 'Apply Create and update Import Contractor', type: :feature, js: true do
  subject do
    within('#titlebar_right') { click_link 'Create and update' }
    expect(page).to have_current_path(importing_contractors_path)
  end

  include_context :login_as_admin
  before { create_list(:vendor, 2) }
  let!(:smtp_connection) { create(:smtp_connection, name: 'test_smtp_conn') }
  let!(:contractor_1) do
    create(:customer, name: 'c1', enabled: false, smtp_connection: nil)
  end
  let!(:contractor_3) do
    create(:vendor, name: 'c3', smtp_connection: nil)
  end

  let!(:import_contractor_1) do
    create :importing_contractor,
           name: 'c1',
           customer: true,
           smtp_connection: smtp_connection,
           smtp_connection_name: smtp_connection.name,
           o_id: contractor_1.id,
           is_changed: false
  end
  let!(:import_contractor_2) do
    create(:importing_contractor, name: 'c2', vendor: true, smtp_connection_name: '', is_changed: false)
  end
  let!(:import_contractor_3) do
    create :importing_contractor,
           name: 'c3',
           vendor: true,
           smtp_connection_name: '',
           is_changed: true,
           o_id: contractor_3.id
  end

  before do
    visit importing_contractors_path
  end

  it 'applies import' do
    subject
    expect(page).to have_selector(
      '.flashes .flash.flash_notice',
      text: 'You have just run importing "Create an update" in the background process, wait until it finishes'
    )
  end

  it 'creates delayed job' do
    expect { subject }.to change { Delayed::Job.count }.by(be >= 1)
  end

  context 'when is_changed=nil' do
    before do
      import_contractor_1.update!(is_changed: nil)
    end

    it 'creates delayed job' do
      expect { subject }.to change { Delayed::Job.count }.by(0)
    end

    it 'shows error' do
      subject

      expect(page).to have_selector(
        '.flashes .flash.flash_error',
        text: 'Apply Unique Columns must be executed before this action'
      )
    end
  end
end
