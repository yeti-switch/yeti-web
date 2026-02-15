# frozen_string_literal: true

RSpec.describe 'Cdrs index page filtering', js: true do
  subject do
    visit cdrs_path
    filter_cdr_records
    within_filters { click_submit('Filter') }
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
        fill_in_tom_select 'TAGGED', with: filter_value
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
          expect(page).to have_field_tom_select('TAGGED', with: filter_value, clearable: true)
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
          expect(page).to have_field_tom_select('TAGGED', with: filter_value, clearable: true)
        end
      end
    end
  end

  describe 'filter by routing tag ids contains' do
    let(:filter_cdr_records) do
      within_filters do
        fill_in_tom_select 'ROUTING TAG IDS CONTAINS', with: filter_value, multiple: true
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
          expect(page).to have_field_tom_select('ROUTING TAG IDS CONTAINS', with: filter_value)
        end
      end
    end
  end

  describe 'filter by customer auth' do
    let(:filter_cdr_records) do
      within_filters do
        fill_in_tom_select 'CUSTOMER AUTH', with: customer_auths[0].name, search: true
      end
    end

    let!(:customer_auths) { FactoryBot.create_list(:customers_auth, 3) }
    let!(:cdrs) do
      [
        FactoryBot.create(:cdr, customer_auth_id: customer_auths[0].id),
        FactoryBot.create(:cdr, customer_auth_id: customer_auths[1].id),
        FactoryBot.create(:cdr, customer_auth_id: customer_auths[2].id)
      ]
    end

    it 'shows filtered records with customer auth' do
      subject
      expect(page).to have_table
      expect(page).to have_table_row(count: 1)
      expect(page).to have_table_cell(column: 'Id', exact_text: cdrs[0].id.to_s)
      expect(page).to have_table_cell(column: 'Customer Auth', exact_text: cdrs[0].customer_auth.display_name)
      within_filters do
        expect(page).to have_field_tom_select('CUSTOMER AUTH', with: customer_auths[0].display_name, clearable: true)
      end
    end
  end
end
