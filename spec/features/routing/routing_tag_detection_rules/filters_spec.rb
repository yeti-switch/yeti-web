# frozen_string_literal: true

RSpec.describe 'Filter Routing Tag detection rule records', :js do
  include_context :login_as_admin
  let!(:routing_tag_detection_rule_list) { create_list :routing_tag_detection_rule, 2 }
  context 'by' do
    context '"ROUTING TAG IDS CONTAINS"' do
      let!(:tag_us) { create :routing_tag, :us }
      let!(:tag_ua) { create :routing_tag, :ua }
      let!(:routing_tag_contains) { create :routing_tag_detection_rule, routing_tag_ids: [tag_us.id, tag_ua.id] }
      it 'should have one record with routing_tags only' do
        visit routing_routing_tag_detection_rules_path
        chosen_pick '#q_routing_tag_ids_array_contains_chosen', text: tag_us.name
        chosen_pick '#q_routing_tag_ids_array_contains_chosen', text: tag_ua.name
        click_button :Filter
        expect(page).to have_css 'table.index_table tbody tr', count: 1
        expect(page).to have_css '.resource_id_link', text: routing_tag_contains.id
      end
    end
  end
end
