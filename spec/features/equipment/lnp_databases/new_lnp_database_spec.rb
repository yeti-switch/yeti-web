# frozen_string_literal: true

RSpec.describe 'Create new LNP Database', type: :feature, js: true do
  subject do
    aa_form.submit
  end

  active_admin_form_for Lnp::Database, 'new'
  include_context :login_as_admin

  before do
    visit new_lnp_database_path(lnp_database: { database_type: database_type })

    aa_form.set_text 'Name', 'test'
  end

  context 'with database type thinq' do
    let(:database_type) { Lnp::Database::CONST::TYPE_THINQ }

    before do
      aa_form.set_text 'Host', 'example.com'
    end

    it 'creates record' do
      subject
      record = Lnp::Database.last
      expect(record).to be_present
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

    include_examples :changes_records_qty_of, Lnp::Database, by: 1
    include_examples :shows_flash_message, :notice, 'Database was successfully created.'
  end
end
