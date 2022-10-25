# frozen_string_literal: true

RSpec.describe 'Index System Event Subscriptions', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    notification_alerts = create_list(:event_subscription, 2)
    visit event_subscriptions_path
    notification_alerts.each do |n_alert|
      expect(page).to have_css('.resource_id_link', text: n_alert.id)
    end
  end
end
