# frozen_string_literal: true

RSpec.describe 'Admin User change password', js: true do
  subject do
    visit change_password_admin_users_path
    fill_form!
    submit_form!
  end

  include_context :login_as_admin
  let(:admin_user_id) { admin_user.id }

  let(:fill_form!) do
    fill_in 'Password*', with: new_password
    fill_in 'Password confirmation', with: new_password
  end
  let(:submit_form!) do
    click_button 'Submit'
  end
  let(:new_password) { 'newpass' }

  it 'changes admin_user password' do
    expect {
      subject
      expect(page).to have_current_path new_admin_user_session_path
    }.to change { admin_user.reload.encrypted_password }
    expect(
      admin_user.valid_password?(new_password)
    ).to eq true
  end

  context 'with empty fields' do
    let(:fill_form!) { nil }

    it 'does not change admin_user password' do
      expect {
        subject
        expect(page).to have_semantic_error_texts(
                          "Password can't be blank",
                          "Password confirmation can't be blank"
                        )
      }.not_to change { admin_user.reload.encrypted_password }
      expect(page).to have_form_error("can't be blank", field: 'Password*')
      expect(page).to have_form_error("can't be blank", field: 'Password confirmation')
    end
  end

  context 'when password mismatch with password_confirmation' do
    let(:fill_form!) do
      fill_in 'Password*', with: new_password
      fill_in 'Password confirmation', with: "#{new_password}a"
    end

    it 'does not change admin_user password' do
      expect {
        subject
        expect(page).to have_semantic_error_texts(
                          "Password confirmation doesn't match Password"
                        )
      }.not_to change { admin_user.reload.encrypted_password }
      expect(page).to have_form_error("doesn't match Password", field: 'Password confirmation')
    end
  end

  context 'when password_confirmation is empty' do
    let(:fill_form!) do
      fill_in 'Password*', with: new_password
    end

    it 'does not change admin_user password' do
      expect {
        subject
        expect(page).to have_semantic_error_texts(
                          "Password confirmation doesn't match Password and can't be blank"
                        )
      }.not_to change { admin_user.reload.encrypted_password }
      expect(page).to have_form_error("doesn't match Password and can't be blank", field: 'Password confirmation')
    end
  end

  context 'when password length < 6' do
    let(:new_password) { '12345' }

    it 'does not change admin_user password' do
      expect {
        subject
        expect(page).to have_semantic_error_texts(
                          'Password is too short (minimum is 6 characters)'
                        )
      }.not_to change { admin_user.reload.encrypted_password }
      expect(page).to have_form_error('is too short (minimum is 6 characters)', field: 'Password*')
    end
  end
end
