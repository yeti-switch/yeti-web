# frozen_string_literal: true

require 'spec_helper'

describe 'Index Gateway Groups', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    gateway_groups = create_list(:gateway_group, 2)
    visit gateway_groups_path
    gateway_groups.each do |gateway_group|
      expect(page).to have_css('.resource_id_link', text: gateway_group.id)
    end
  end
end
