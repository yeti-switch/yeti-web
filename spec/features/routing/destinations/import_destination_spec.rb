# frozen_string_literal: true

RSpec.describe 'Destination imports', type: :feature do
  include_context :login_as_admin

  subject { visit destination_imports_path }

  context 'with importing destination items' do
    let!(:importing_destination) { create(:importing_destination) }

    it 'should have table with items' do
      subject
      expect(page).to have_table
      within_table_row(id: importing_destination.id) do
        expect(page).to have_table_cell(text: 'Fixed', column: 'Rate Policy')
      end
    end
  end

  context 'without importing destintaion items' do
    it 'shouldn`t have table with items' do
      subject
      expect(page).to_not have_table
      expect(page).to have_text('There are no Destination Imports yet.')
    end
  end
end
