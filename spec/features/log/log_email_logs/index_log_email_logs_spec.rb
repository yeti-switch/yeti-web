# frozen_string_literal: true

require 'spec_helper'

describe 'Index Log Email logs', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    log_email_logs = create_list(:email_log, 2)
    visit log_email_logs_path
    log_email_logs.each do |log_email_log|
      expect(page).to have_css('.resource_id_link', text: log_email_log.id)
    end
  end
end
