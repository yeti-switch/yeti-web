RSpec.describe 'Cdrs index page filtering', js: true do
  subject do
    within_filters { click_submit('Filter') }
  end

  include_context :login_as_admin

  before do
    Cdr::Cdr.delete_all
    visit cdrs_path

    within_filters do
      select_by_value tagged_filter_value, from: 'Tagged'
    end
  end

  let!(:cdrs) { create_list(:cdr, 2) }
  let!(:tag) { create :routing_tag }
  let!(:cdr_tagged) { create :cdr, routing_tag_ids: [tag.id] }
  let(:tagged_filter_value) { nil }

  context 'with filter by tagged' do
    let(:tagged_filter_value) { true }

    it 'shows filtered records with routing_tags' do
      subject
      expect(page).to have_table
      expect(page).to have_table_row count: 1
      expect(page).to have_table_cell column: 'Id', text: cdr_tagged.id
      expect(page).to have_select :Tagged, selected: 'Yes'
    end
  end

  context 'with filter by not tagged' do
    let(:tagged_filter_value) { false }

    it 'shows filtered records without routing_tags' do
      subject
      expect(page).to have_table
      expect(page).to have_table_row count: 2
      expect(page).to have_table_cell column: 'Id', text: cdrs.first.id
      expect(page).to have_select :Tagged, selected: 'No'
    end
  end

  context 'with filter by any tagged' do
    it 'shows filtered records without routing_tags' do
      subject
      expect(page).to have_table
      expect(page).to have_table_row count: Cdr::Cdr.count
      expect(page).to have_table_cell column: 'Id', text: cdrs.first.id
      expect(page).to have_table_cell column: 'Id', text: cdr_tagged.id
      expect(page).to have_select :Tagged, selected: 'Any'
    end
  end

  context 'with filter by routing tag ids contains' do
    let(:tagged_filter_value) { tag.name }

    it 'shows filtered records with contains ids' do
      within_filters do
        fill_in_chosen 'Routing Tag IDs Contains', with: tagged_filter_value
      end

      subject
      expect(page).to have_table
      expect(page).to have_table_row count: 1
      expect(page).to have_table_cell column: 'Id', text: cdr_tagged.id
      expect(page).to have_select 'q_routing_tag_ids_array_contains', selected: tagged_filter_value
    end
  end
end
