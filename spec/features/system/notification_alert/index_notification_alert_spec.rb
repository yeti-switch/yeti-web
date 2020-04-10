# frozen_string_literal: true

require 'spec_helper'

describe 'Index System Notification Alerts', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    notification_alerts = create_list(:notification_alert, 2)
    visit notification_alerts_path
    notification_alerts.each do |n_alert|
      expect(page).to have_css('.resource_id_link', text: n_alert.id)
    end
  end
end
