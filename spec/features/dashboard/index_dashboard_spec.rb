# frozen_string_literal: true

require 'spec_helper'

describe 'Index Dashboard', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    items = create_list(:event, 5, :uniq_command)
    visit dashboard_path
    items.each do |item|
      expect(page).to have_css('td.col-command', text: item.command)
    end
  end
end
