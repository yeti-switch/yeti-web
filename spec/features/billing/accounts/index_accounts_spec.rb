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
end
