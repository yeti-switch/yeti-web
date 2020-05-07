# frozen_string_literal: true

require 'spec_helper'

describe 'Index System Networks', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    system_networks = create_list(:network, 2, :filled, :uniq_name)
    visit system_networks_path
    system_networks.each do |system_network|
      expect(page).to have_css('.resource_id_link', text: system_network.id)
    end
  end
end
