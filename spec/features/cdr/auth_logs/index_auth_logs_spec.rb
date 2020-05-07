# frozen_string_literal: true

require 'spec_helper'

describe 'Auth Logs Index', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    auth_logs = create_list(:auth_log, 2, :with_id)
    visit auth_logs_path
    auth_logs.each do |auth_log|
      expect(page).to have_css('.resource_id_link', text: auth_log.id)
    end
  end
end
