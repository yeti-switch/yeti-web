# frozen_string_literal: true

require 'spec_helper'

describe 'Copy Routing group with dialpeers action', type: :feature do
  include_context :login_as_admin

  let!(:routing_group) do
    create(:routing_group)
  end

  before do
    create_list(:dialpeer, 2, routing_group: routing_group)
  end

  let(:new_name) { routing_group.name + '_copy' }

  before { visit routing_group_path(routing_group.id) }

  before do
    click_link('Copy with dialpeers', exact_text: true)
    within '#new_routing_routing_group_duplicator' do
      fill_in('Name', with: new_name)
      find('input[type=submit]').click
    end
    # find('h2', text: 'Dialpeers') # wait page load
  end

  it 'creates new Routing group with duplicated Dialpeers' do
    expect(page).to have_css('.flash_notice', text: 'Routing group duplicator was successfully created.')

    expect(routing_group.reload.dialpeers.count).to eq(2)
    expect(RoutingGroup.count).to eq(2)
    expect(RoutingGroup.last.dialpeers.count).to eq(2)
  end
end
