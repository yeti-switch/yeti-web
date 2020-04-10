# frozen_string_literal: true

require 'spec_helper'

describe 'Index System Network Types', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    system_network_types = create_list(:network_type, 2, :filled)
    visit system_network_types_path
    system_network_types.each do |system_network_type|
      expect(page).to have_css('.resource_id_link', text: system_network_type.id)
    end
  end
end
