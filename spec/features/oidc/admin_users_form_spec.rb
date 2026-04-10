# frozen_string_literal: true

RSpec.describe 'AdminUsers admin UI under OIDC mode', type: :feature, oidc_mode: true do
  let!(:admin_user) do
    create(:admin_user, :filled,
           username: 'ops',
           provider: 'oidc',
           uid: 'ops-sub',
           roles: %w[admin])
  end

  before do
    login_as(admin_user, scope: :admin_user)
  end

  it 'does not expose the New Admin User action' do
    visit admin_admin_users_path
    expect(page).not_to have_link('New Admin User')
  end

  it 'does not render password fields on the edit form' do
    visit edit_admin_admin_user_path(admin_user)
    expect(page).not_to have_field('Password')
    expect(page).not_to have_field('Password confirmation')
  end

  it 'does not let the admin change username from the edit form' do
    visit edit_admin_admin_user_path(admin_user)
    expect(page).not_to have_field('Username')
  end

  it 'still allows editing allowed_ips' do
    visit edit_admin_admin_user_path(admin_user)
    expect(page).to have_field('Allowed ips')
  end
end
