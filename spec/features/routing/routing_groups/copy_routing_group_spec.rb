# frozen_string_literal: true

require 'spec_helper'

describe 'Copy Routing group action', type: :feature do
  include_context :login_as_admin

  context 'success' do
    let!(:routing_group) do
      create(:routing_group).reload # after_save
    end

    let(:new_name) { routing_group.name + '_copy' }

    before { visit routing_group_path(routing_group.id) }

    before do
      click_link('Copy', exact_text: true)
      within '#new_routing_group' do
        fill_in('routing_group_name', with: new_name)
      end
    end

    subject do
      find('input[type=submit]').click
      find('h3', text: 'Routing Group Details') # wait page reload
    end

    it 'creates new Routing group with identical fields, except name' do
      subject
      expect(routing_group.dialpeers.count).to eq(0)
      expect(RoutingGroup.count).to eq(2)
      expect(RoutingGroup.last).to have_attributes(
        name: new_name
      )
    end
  end
end
