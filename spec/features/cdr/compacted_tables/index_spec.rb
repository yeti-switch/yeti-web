# frozen_string_literal: true

RSpec.describe 'Compacted Tables Index', :js do
  include_context :login_as_admin

  subject { visit compacted_tables_path }

  let!(:cdr_compacted_tables) do
    FactoryBot.create_list(:cdr_compacted_table, 3)
  end

  it 'should render filter page properly' do
    subject

    cdr_compacted_tables.each do |table|
      expect(page).to have_table_cell(column: 'Table Name', exact_text: table.table_name)
      expect(page).to have_table_cell(column: 'Created At', exact_text: table.created_at.to_fs(:db))
    end
  end
end
