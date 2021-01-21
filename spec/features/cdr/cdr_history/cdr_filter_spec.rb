RSpec.describe 'Cdrs index page', type: :feature, js: true do
  subject do
    within_filters { click_submit('Filter') }
  end

  include_context :login_as_admin
  let!(:cdrs) { create_list(:cdr, 2) }

  before do
    Cdr::Cdr.delete_all
    visit cdrs_path
  end

  describe 'filtering', js: true do
    context 'with filter by Tagged' do
      # before do
      #
      # end

      let!(:tag) { create :routing_tag }
      let!(:cdr_tagged) { create :cdr, routing_tag_ids: [tag.id] }

      it 'shows filtered records with routing_tags' do
        within_filters do
          select :Yes, from: :Tagged
        end

        subject
        expect(page).to have_table
        expect(page).to have_table_row count: 1
        expect(page).to have_table_cell column: 'Id', text: cdr_tagged.id
        expect(page).to have_select :Tagged, selected: 'Yes'
      end

      it 'shows filtered records without routing_tags' do
        within_filters do
          select :No, from: :Tagged
        end

        subject
        expect(page).to have_table
        expect(page).to have_table_row count: 2
        expect(page).to have_table_cell column: 'Id', text: cdrs.first.id
        expect(page).to have_select :Tagged, selected: 'No'
      end
    end
  end
end
