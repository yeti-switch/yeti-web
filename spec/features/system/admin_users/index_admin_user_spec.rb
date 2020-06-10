# frozen_string_literal: true

RSpec.describe 'Index Admin Users', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    admin_users = create_list(:admin_user, 2, :filled)
    visit admin_users_path
    admin_users.each do |admin_user|
      expect(page).to have_css('.resource_id_link', text: admin_user.id)
    end
  end
end
