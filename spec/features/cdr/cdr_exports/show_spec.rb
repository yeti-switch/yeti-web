# frozen_string_literal: true

RSpec.describe 'CDR export show page' do
  include_context :login_as_admin

  context 'when valid data' do
    let!(:record) { create(:cdr_export, :completed) }

    before { visit cdr_export_path(record) }

    it 'should render show page properly' do
      expect(page).to have_page_title record.decorate.display_name
      expect(page).to have_sidebar 'History'
      expect(page).to have_action_item 'History'
    end
  end
end
