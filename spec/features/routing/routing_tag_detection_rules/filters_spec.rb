# frozen_string_literal: true

RSpec.describe 'Filter Routing Tag detection rule records', :js do
  subject do
    visit routing_routing_tag_detection_rules_path
    filter_records
    within_filters { click_submit('Filter') }
  end

  include_context :login_as_admin

  let!(:routing_tag_detection_rule_list) { create_list :routing_tag_detection_rule, 2 }

  describe 'Filter by routing tags' do
    let(:filter_records) do
      within_filters do
        fill_in_chosen 'Routing Tag IDs Contains', with: tags.first.name, multiple: true
        fill_in_chosen 'Routing Tag IDs Contains', with: tags.second.name, multiple: true
        expect(page).to have_field_chosen('Routing Tag IDs Contains', with: tags.first.name, exact: false)
        expect(page).to have_field_chosen('Routing Tag IDs Contains', with: tags.second.name, exact: false)
      end
    end

    context '"ROUTING TAG IDS CONTAINS"' do
      let(:tags) { create_list(:routing_tag, 2) }

      let!(:routing_tag_contains) { create :routing_tag_detection_rule, routing_tag_ids: [tags.first.id, tags.second.id] }

      it 'returns record with routing_tags only' do
        subject

        expect(page).to have_table
        expect(page).to have_table_row count: 1
        expect(page).to have_table_cell column: 'Id', text: routing_tag_contains.id
      end
    end
  end
end
