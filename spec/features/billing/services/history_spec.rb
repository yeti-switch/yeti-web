# frozen_string_literal: true

RSpec.describe 'Billing Services History' do
  include_context :login_as_admin

  let!(:account) { create(:account) }
  let!(:service_type) { create(:service_type) }
  let!(:record) { create(:service, :renew_daily, name: 'test', account:, type: service_type) }

  subject { visit history_service_path(record.id) }

  it 'renders the history page' do
    subject
    expect(page).to have_content 'History'
  end

  it 'lists the version item decorated with its display name' do
    subject
    within_panel('History') do
      expect(page).to have_link record.decorate.display_name
    end
  end
end
