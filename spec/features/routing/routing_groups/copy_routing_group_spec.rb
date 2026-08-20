# frozen_string_literal: true

RSpec.describe 'Copy Routing group action', type: :feature do
  include_context :login_as_admin

  context 'success' do
    let!(:routing_group) do
      create(:routing_group).reload # after_save
    end

    let(:new_name) { routing_group.name + '_copy' }

    before { visit routing_routing_group_path(routing_group.id) }

    before do
      click_link('Copy', exact_text: true)
      within '#new_routing_routing_group' do
        fill_in('routing_routing_group_name', with: new_name)
      end
    end

    subject do
      find('input[type=submit]').click
      # ActiveAdmin 3's `attributes_table` wrapped itself in a panel titled
      # "<Resource> Details"; AA4 renders the table with no panel and no heading,
      # so wait for the table itself instead.
      expect(page).to have_selector('.attributes-table') # wait page reload
    end

    it 'creates new Routing group with identical fields, except name' do
      expect { subject }.to change { Routing::RoutingGroup.count }.by(1)
      expect(routing_group.dialpeers.count).to eq(0)
      expect(Routing::RoutingGroup.last).to have_attributes(
        name: new_name
      )
    end
  end
end
