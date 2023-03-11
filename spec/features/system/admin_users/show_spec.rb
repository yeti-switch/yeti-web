# frozen_string_literal: true

RSpec.describe 'Admin User show', js: true do
  subject do
    visit admin_user_path(admin_user_id)
  end

  include_context :login_as_admin
  let(:admin_user_id) { admin_user.id }

  it 'has Change Password link for myself' do
    subject
    have_attribute_row('ID', exact_text: admin_user.id.to_s)
    have_attribute_row('USERNAME', exact_text: admin_user.username)
    have_attribute_row('EMAIL', exact_text: admin_user.email)
    expect(page).not_to have_text(admin_user.encrypted_password)

    expect(page).to have_link 'Change Password', href: change_password_admin_users_path
  end

  context 'when other admin_user' do
    let!(:another_admin_user) { FactoryBot.create(:admin_user) }
    let(:admin_user_id) { another_admin_user.id }

    it 'does not have Change Password link' do
      subject
      have_attribute_row('ID', exact_text: another_admin_user.id.to_s)
      have_attribute_row('USERNAME', exact_text: another_admin_user.username)
      have_attribute_row('EMAIL', exact_text: another_admin_user.email)
      expect(page).not_to have_text(another_admin_user.encrypted_password)

      expect(page).not_to have_link 'Change Password'
    end
  end
end
