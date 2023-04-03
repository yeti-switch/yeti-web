# frozen_string_literal: true

RSpec.describe 'Routing Tag Detection Rule Imports', type: :feature do
  subject { visit routing_tag_detection_rule_imports_path }

  include_context :login_as_admin

  context 'with imports' do
    let!(:importing_routing_tag_detection_rule) { FactoryBot.create(:importing_routing_tag_detection_rule, src_prefix: '111', dst_prefix: '222') }

    it 'should have table with items' do
      subject
      expect(page).to have_table
      within_table_row(id: importing_routing_tag_detection_rule.id) do
        expect(page).to have_table_cell(column: 'Routing Tags', text: '')
        expect(page).to have_table_cell(column: 'Src Area', text: 'any')
        expect(page).to have_table_cell(column: 'Src Area', text: 'any')
        expect(page).to have_table_cell(column: 'Src prefix', text: '111')
        expect(page).to have_table_cell(column: 'Dst prefix', text: '222')
        expect(page).to have_table_cell(column: 'Tag Action', text: 'Clear tags')
        expect(page).to have_table_cell(column: 'Tag Action Value', text: '')
      end
    end
  end

  context 'without imports' do
    it 'shouldn`t have table with items' do
      subject
      expect(page).to_not have_table
      expect(page).to have_text('There are no Routing Tag Detection Rule Imports yet.')
    end
  end
end
