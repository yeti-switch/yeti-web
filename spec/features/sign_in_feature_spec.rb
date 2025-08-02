# frozen_string_literal: true

RSpec.describe 'the sign in process', js: true do
  subject do
    visit new_admin_user_session_path
    fill_form!
    click_button 'Login'
  end

  let!(:admin_user) { FactoryBot.create(:admin_user, admin_user_attrs) }
  let(:admin_user_attrs) { { password: 'passwd' } }

  shared_examples :signs_in_successfully do
    it 'signs in successfully' do
      subject
      expect(page).to have_current_path root_path
      expect(page).to have_flash_message 'Signed in successfully.', type: :notice
    end
  end

  shared_examples :does_not_sign_in do |message|
    it 'does not sign in' do
      subject
      expect(page).to have_current_path new_admin_user_session_path
      expect(page).to have_flash_message message, type: :alert
    end
  end

  let(:fill_form!) do
    fill_in 'Username', with: admin_user.username
    fill_in 'Password', with: admin_user_attrs[:password]
  end

  context 'with correct username and password' do
    include_examples :signs_in_successfully
  end

  context 'when password not match' do
    let(:fill_form!) do
      fill_in 'Username', with: admin_user.username
      fill_in 'Password', with: 'invalid'
    end

    include_examples :does_not_sign_in, 'Invalid email or password.'
  end

  context 'when invalid non-exist username' do
    let(:fill_form!) do
      fill_in 'Username', with: 'non-exist'
      fill_in 'Password', with: admin_user_attrs[:password]
    end

    include_examples :does_not_sign_in, 'Invalid Username or password.'
  end

  context 'when allowed_ips are filled with not match ip' do
    let(:admin_user_attrs) do
      super().merge allowed_ips: ['192.168.1.123']
    end

    include_examples :does_not_sign_in, 'Your IP address is not allowed.'
  end

  context 'when allowed_ips are filled with match ip' do
    let(:admin_user_attrs) do
      super().merge allowed_ips: ['127.0.0.0/24']
    end

    include_examples :signs_in_successfully
  end

  context 'when current admin user has NOT access to dashboard content', js: false do
    let(:admin_user_attrs) { super().merge roles: ['user'] }

    before do
      allow(Rails.configuration).to receive(:policy_roles).and_return(
        {
          :user => {
            :Dashboard => {
              :read => true,
              :details => false
            }
          }
        }
      )
      visit new_admin_user_session_path
    end

    it 'should render dashboard page without any content' do
      fill_form!
      click_button 'Login'
      expect(page).to have_selector('small', text: 'You have limited access to dashboard content.')
      expect(page).to have_current_path root_path
    end
  end
end
