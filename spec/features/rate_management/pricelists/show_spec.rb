# frozen_string_literal: true

RSpec.describe 'Rate Management Pricelist Show' do
  include_context :login_as_admin

  context 'when valid data' do
    let!(:record) { FactoryBot.create(:rate_management_pricelist, :with_project) }

    before { visit rate_management_pricelist_path(record) }

    it 'should render show page properly' do
      expect(page).to have_http_status :ok
      expect(page).to have_page_title record.display_name
      expect(page).to have_sidebar('History')
      expect(page).to have_action_item('History')
    end
  end
end
