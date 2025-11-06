# frozen_string_literal: true

RSpec.describe 'Index Accounts', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    accounts = create_list(:account, 2, :filled)
    visit accounts_path
    accounts.each do |account|
      expect(page).to have_css('.resource_id_link', text: account.id)
    end
  end

  describe 'filter', :js do
    subject { click_button :Filter }

    context 'by contractor' do
      let!(:contractor) { FactoryBot.create(:contractor, name: 'John Doe', customer: true) }
      let!(:record) { FactoryBot.create(:account, :filled, name: 'John Doe', contractor:) }

      before { visit accounts_path }

      it 'should return filtered records only' do
        tom_select contractor.id, from: '#q_contractor_id_eq', search_query: contractor.name
        subject
        expect(page).to have_select 'q[contractor_id_eq]', selected: contractor.display_name
        expect(page).to have_table_row count: 1
        expect(page).to have_table_cell column: :id, exact_text: record.id.to_s
      end
    end
  end
end
