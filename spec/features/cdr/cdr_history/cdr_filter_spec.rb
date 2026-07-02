# frozen_string_literal: true

RSpec.describe 'Cdrs index page filtering', js: true do
  subject do
    visit cdrs_path
    filter_cdr_records
    within_filters { click_submit('Filter') }
  end

  include_context :login_as_admin
  include_context :clean_cdr_db

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
          expect(page).to have_field_tom_select('TAGGED', with: filter_value)
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
          expect(page).to have_field_tom_select('TAGGED', with: filter_value)
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

  describe 'filter by orig gw' do
    let!(:gateways) { create_list(:gateway, 3) }
    let!(:cdrs) { gateways.map { |gw| create(:cdr, orig_gw_id: gw.id) } }

    let(:filter_cdr_records) do
      within_filters do
        select_tom_select_by_value 'ORIGINATION GATEWAY',
                                   gateways[0].id => gateways[0].name,
                                   gateways[1].id => gateways[1].name
      end
    end

    it 'shows only CDRs matching selected orig gateways' do
      subject
      expect(page).to have_table
      expect(page).to have_table_row(count: 2)
      expect(page).to have_table_cell(column: 'Id', text: cdrs[0].id.to_s)
      expect(page).to have_table_cell(column: 'Id', text: cdrs[1].id.to_s)
    end
  end

  describe 'filter by internal disconnect code' do
    let!(:disconnect_codes) { create_list(:disconnect_code, 3, :ts) }
    let!(:cdrs) { disconnect_codes.map { |dc| create(:cdr, internal_disconnect_code_id: dc.id) } }

    let(:filter_cdr_records) do
      within_filters do
        fill_in_tom_select 'INTERNAL DISCONNECT CODE',
                           with: disconnect_codes[0].display_name,
                           search: disconnect_codes[0].code.to_s
      end
    end

    it 'shows only CDRs matching the selected internal disconnect code' do
      subject
      expect(page).to have_table
      expect(page).to have_table_row(count: 1)
      expect(page).to have_table_cell(column: 'Id', text: cdrs[0].id.to_s)
    end
  end

  describe 'filter by term gw' do
    let!(:gateways) { create_list(:gateway, 3) }
    let!(:cdrs) { gateways.map { |gw| create(:cdr, term_gw_id: gw.id) } }

    let(:filter_cdr_records) do
      within_filters do
        select_tom_select_by_value 'TERMINATION GATEWAY',
                                   gateways[0].id => gateways[0].name,
                                   gateways[1].id => gateways[1].name
      end
    end

    it 'shows only CDRs matching selected term gateways' do
      subject
      expect(page).to have_table
      expect(page).to have_table_row(count: 2)
      expect(page).to have_table_cell(column: 'Id', text: cdrs[0].id.to_s)
      expect(page).to have_table_cell(column: 'Id', text: cdrs[1].id.to_s)
    end
  end

  describe 'filter by customer auth' do
    let(:filter_cdr_records) do
      within_filters do
        fill_in_tom_select 'CUSTOMER AUTH', with: customer_auths[0].name, search: true, exact_label: true
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
        expect(page).to have_field_tom_select('CUSTOMER AUTH', exact_label: true, with: customer_auths[0].display_name)
      end
    end
  end
end
