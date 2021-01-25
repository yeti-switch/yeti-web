# frozen_string_literal: true

RSpec.describe 'Cdrs index page filtering', js: true do
  subject do
    visit cdrs_path
    filter_cdr_records
    within_filters { click_submit('Filter') }
  end

  before do
    Cdr::Cdr.delete_all
  end

  include_context :login_as_admin

  let(:filter_value) { nil }

  let!(:tags) { create_list(:routing_tag, 4) }
  let!(:cdrs_not_tagged) do
    [
      create(:cdr, routing_tag_ids: []),
      create(:cdr, routing_tag_ids: nil)
    ]
  end
  let!(:cdrs_tagged) do
    [
      create(:cdr, routing_tag_ids: [tags.first.id]),
      create(:cdr, routing_tag_ids: [tags.second.id, tags.third.id]),
      create(:cdr, routing_tag_ids: [tags.first.id, tags.fourth.id])
    ]
  end

  describe 'filter by tagged' do
    let(:filter_cdr_records) do
      within_filters do
        fill_in_chosen 'Tagged', with: filter_value
      end
    end

    context 'with filter by tagged' do
      let(:filter_value) { 'Yes' }

      it 'shows filtered records with routing_tags' do
        subject
        expect(page).to have_table
        expect(page).to have_table_row count: cdrs_tagged.size
        cdrs_tagged.each { |cdr| expect(page).to have_table_cell column: 'Id', text: cdr.id }
        within_filters do
          expect(page).to have_field_chosen('Tagged', with: filter_value)
        end
      end
    end

    context 'with filter by not tagged' do
      let(:filter_value) { 'No' }

      it 'shows filtered records without routing_tags' do
        subject
        expect(page).to have_table
        expect(page).to have_table_row count: cdrs_not_tagged.size
        cdrs_not_tagged.each { |cdr| expect(page).to have_table_cell column: 'Id', text: cdr.id }
        within_filters do
          expect(page).to have_field_chosen('Tagged', with: filter_value)
        end
      end
    end
  end

  describe 'filter by routing tag ids contains' do
    let(:filter_cdr_records) do
      within_filters do
        fill_in_chosen 'Routing Tag IDs Contains', with: filter_value, multiple: true
      end
    end

    context 'with filter by routing tag ids contains' do
      let(:filter_value) { tags.first.name }
      let(:tag_id) { tags.first.id }
      let(:filtered_cdrs) { cdrs_tagged.filter { |cdr| cdr.routing_tag_ids.include? tag_id } }

      it 'shows filtered records with contains ids' do
        subject
        expect(page).to have_table
        expect(page).to have_table_row count: filtered_cdrs.size
        filtered_cdrs.each { |cdr| expect(page).to have_table_cell column: 'Id', text: cdr.id }
        within_filters do
          expect(page).to have_field_chosen('Routing Tag IDs Contains', with: filter_value)
        end
      end
    end
  end
end
