# frozen_string_literal: true

RSpec.describe 'numberlist item imports', 'filter' do
  include_context :login_as_admin

  subject { click_button :Filter }

  context 'by REJECT action' do
    let!(:record) { FactoryBot.create(:importing_numberlist_item, action_id: Routing::NumberlistItem::ACTION_REJECT) }

    before do
      FactoryBot.create(:importing_numberlist_item, action_id: Routing::NumberlistItem::ACTION_ACCEPT)
      visit numberlist_item_imports_path
      fill_in_tom_select 'Action', with: Routing::NumberlistItem::ACTIONS.fetch(Routing::NumberlistItem::ACTION_REJECT)
    end

    it 'should render filtered records only', :js do
      subject

      expect(page).to have_field_tom_select('Action', with: Routing::NumberlistItem::ACTIONS.fetch(Routing::NumberlistItem::ACTION_REJECT))
      expect(page).to have_table_row count: 1
      expect(page).to have_table_cell column: :Id, exact_text: record.id.to_s
      expect(page).to have_table_cell column: :Action, exact_text: Routing::NumberlistItem::ACTIONS.fetch(Routing::NumberlistItem::ACTION_REJECT)
    end
  end
end
