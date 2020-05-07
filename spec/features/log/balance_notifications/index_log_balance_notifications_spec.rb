# frozen_string_literal: true

require 'spec_helper'

describe 'Index Log Balance Notifications', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    log_balance_notifications = create_list(:balance_notification, 2)
    visit log_balance_notifications_path
    log_balance_notifications.each do |log_balance_notification|
      expect(page).to have_css('.resource_id_link', text: log_balance_notification.id)
    end
  end
end
