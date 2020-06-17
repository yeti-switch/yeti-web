# frozen_string_literal: true

RSpec.describe 'Filter Destination records', :js do
  include_context :login_as_admin
  let!(:other_dialpeers) { create_list :dialpeer, 2 }
  before { visit dialpeers_path }

  context 'by' do
    context '"TAGGED"' do
      let!(:tag) { create :routing_tag }
      let!(:dialpeer_tagged) { create :dialpeer, routing_tag_ids: [tag.id] }

      it 'should have record with any tag' do
        select :Yes, from: :Tagged
        click_button :Filter
        expect(page).to have_css 'table.index_table tbody tr', count: 1
        expect(page).to have_css '.resource_id_link', text: dialpeer_tagged.id
        expect(page).to have_select :Tagged, selected: 'Yes'
      end

      it 'should have record without any tag' do
        select :No, from: :Tagged
        click_button :Filter
        expect(page).to have_css('table.index_table tbody tr', count: other_dialpeers.count)
        expect(page).to have_select :Tagged, selected: 'No'
        other_dialpeers.each { |p| expect(page).to have_css '.resource_id_link', text: p.id }
      end
    end

    context '"ROUTING TAG IDS CONTAINS"' do
      let!(:tag_us) { create :routing_tag, :us }
      let!(:tag_ua) { create :routing_tag, :ua }
      let!(:dialpeer_tag_countains) { create :dialpeer, routing_tag_ids: [tag_us.id, tag_ua.id] }

      it 'should have one record with routing_tag only' do
        visit dialpeers_path
        chosen_pick '#q_routing_tag_ids_array_contains_chosen', text: tag_us.name
        chosen_pick '#q_routing_tag_ids_array_contains_chosen', text: tag_ua.name
        click_button :Filter
        expect(page).to have_css 'table.index_table tbody tr', count: 1
        expect(page).to have_css '.resource_id_link', text: dialpeer_tag_countains.id
      end
    end
  end
end
