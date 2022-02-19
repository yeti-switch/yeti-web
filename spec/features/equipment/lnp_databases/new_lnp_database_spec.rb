# frozen_string_literal: true

RSpec.describe 'Create new LNP Database', type: :feature, js: true do
  subject do
    visit new_lnp_database_path(index_params)
    fill_form!
    submit_form!
  end

  include_context :login_as_admin

  let(:index_params) do
    { lnp_database: { database_type: database_type } }
  end
  let(:fill_form!) { nil }
  let(:submit_form!) do
    click_submit('Create Database')
  end

  context 'with database type thinq' do
    let(:database_type) { Lnp::Database::CONST::TYPE_THINQ }
    let(:fill_form!) do
      fill_in 'Name', with: 'test'
      fill_in 'Host', with: 'example.com'
    end

    it 'creates record' do
      expect {
        subject
        expect(page).to have_flash_message('Database was successfully created.', type: :notice, exact: true)
      }.to change { Lnp::Database.count }.by(1)

      record = Lnp::Database.last
      expect(record).to have_attributes(
        name: 'test',
        database_type: database_type
      )
      expect(record.database).to have_attributes(
        host: 'example.com',
        port: nil,
        username: '',
        token: '',
        timeout: 300
      )
    end
  end

  context 'with invalid database type' do
    let(:database_type) { 'foobar' }
    let(:fill_form!) { nil }
    let(:submit_form!) { nil }

    it 'redirects to index with an error' do
      subject
      expect(page).to have_current_path lnp_databases_path
      expect(page).to have_flash_message('invalid database type "foobar"', type: :error, exact: true)
    end
  end

  context 'with empty params' do
    let(:index_params) { nil }
    let(:fill_form!) { nil }
    let(:submit_form!) { nil }

    it 'redirects to index with an error' do
      subject
      expect(page).to have_current_path lnp_databases_path
      expect(page).to have_flash_message('invalid database type nil', type: :error, exact: true)
    end
  end
end
