# frozen_string_literal: true

RSpec.describe 'Index Numberlist Item', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    numberlist_items = create_list(:numberlist_item, 2, :filled)
    visit routing_numberlist_items_path
    numberlist_items.each do |numberlist_item|
      expect(page).to have_css('.resource_id_link', text: numberlist_item.id)
      expect(page).to have_table_cell column: :Action, exact_text: Routing::NumberlistItem::ACTIONS.fetch(numberlist_item.action_id)
    end
  end
end
