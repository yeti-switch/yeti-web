# frozen_string_literal: true

require 'spec_helper'

describe 'Index Log Logic Log', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    logic_logs = create_list(:logic_log, 2)
    visit logic_logs_path
    logic_logs.each do |logic_log|
      expect(page).to have_css('.resource_id_link', text: logic_log.id)
    end
  end
end
