# frozen_string_literal: true

RSpec.describe 'Filter Destination records', :js do
  include_context :login_as_admin
  let!(:other_destinations_list) { create_list :destination, 2 }

  context 'by' do
    context '"TAGGED"' do
      let!(:tag) { create :routing_tag, :ua }
      let!(:customers_auth_tagged) { create :destination, routing_tag_ids: [tag.id] }

      it 'should have records with any tag' do
        visit destinations_path
        select :Yes, from: :Tagged
        click_button :Filter
        expect(page).to have_css 'table.index_table tbody tr', count: 1
        expect(page).to have_css '.resource_id_link', text: customers_auth_tagged.id
        expect(page).to have_select :Tagged, selected: 'Yes'
      end

      it 'should have record without any tag' do
        visit destinations_path
        select :No, from: :Tagged
        click_button :Filter
        expect(page).to have_css 'table.index_table tbody tr', count: other_destinations_list.count
        expect(page).to have_select :Tagged, selected: 'No'
        other_destinations_list.each { |d| expect(page).to have_css('.resource_id_link', text: d.id) }
      end
    end

    context '"ROUTING TAG IDS CONTAINS"' do
      let!(:tag_us) { create :routing_tag }
      let!(:tag_ua) { create :routing_tag }
      let!(:destinations_tag_contains) { create :destination, routing_tag_ids: [tag_us.id, tag_ua.id] }

      it 'should have one record with routing_tag only' do
        visit destinations_path
        chosen_pick '#q_routing_tag_ids_array_contains_chosen', text: tag_us.name
        chosen_pick '#q_routing_tag_ids_array_contains_chosen', text: tag_ua.name
        click_button :Filter
        expect(page).to have_css 'table.index_table tbody tr', count: 1
        expect(page).to have_css '.resource_id_link', text: destinations_tag_contains.id
      end
    end
  end
end
