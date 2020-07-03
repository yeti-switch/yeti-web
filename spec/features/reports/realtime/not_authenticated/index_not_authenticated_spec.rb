# frozen_string_literal: true

RSpec.describe 'Index Report Realtime Not Authenticated' do
  include_context :login_as_admin

  it 'should have records' do
    not_authenticates = FactoryBot.create_list(:not_authenticated, 2)
    visit report_realtime_not_authenticateds_path
    not_authenticates.each do |routing|
      expect(page).to have_css '.col-auth_orig_ip', text: routing.auth_orig_ip
    end
  end
end
