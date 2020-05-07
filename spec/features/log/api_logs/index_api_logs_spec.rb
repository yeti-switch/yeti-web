# frozen_string_literal: true

require 'spec_helper'

describe 'Index Log Api Logs', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    api_logs = create_list(:api_log, 2)
    visit api_logs_path
    api_logs.each do |api_log|
      expect(page).to have_css('.resource_id_link', text: api_log.id)
    end
  end
end
