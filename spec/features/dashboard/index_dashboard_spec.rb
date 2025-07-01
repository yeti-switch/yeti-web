# frozen_string_literal: true

RSpec.describe 'Index Dashboard', type: :feature do
  subject do
    visit dashboard_path
  end

  include_context :login_as_admin

  it 'renders dashboard' do
    subject
    expect(page).to have_current_path dashboard_path
  end

  context 'when admin_user.allowed_ips match request.remote_ip' do
    before do
      admin_user.update! allowed_ips: ['127.0.0.1']
    end

    it 'renders dashboard' do
      subject
      expect(page).to have_current_path dashboard_path
    end
  end

  context 'when admin_user.allowed_ips does not match request.remote_ip' do
    before do
      admin_user.update! allowed_ips: ['10.1.2.3']
    end

    it 'does not sign in' do
      subject
      expect(page).to have_current_path new_admin_user_session_path
      expect(page).to have_flash_message 'Your IP address is not allowed.', type: :alert
    end
  end
end
