# frozen_string_literal: true

RSpec.describe 'Copy Routing group with dialpeers action', type: :feature do
  subject do
    visit routing_routing_group_path(routing_group.id)
    click_link('Copy with dialpeers', exact_text: true)
    within '#new_routing_routing_group_duplicator_form' do
      fill_in('Name', with: new_name)
      find('input[type=submit]').click
    end
    # find('h2', text: 'Dialpeers') # wait page load
  end

  include_context :login_as_admin

  let!(:routing_group) do
    create(:routing_group)
  end

  before do
    create_list(:dialpeer, 2, routing_group: routing_group)
  end

  let(:new_name) { routing_group.name + '_copy' }

  it 'creates new Routing group with duplicated Dialpeers' do
    expect { subject }.to change { Routing::RoutingGroup.count }.by(1)
    expect(page).to have_css('.flash_notice', text: 'Routing group duplicator was successfully created.')
    expect(routing_group.reload.dialpeers.count).to eq(2)
    expect(Routing::RoutingGroup.last.dialpeers.count).to eq(2)
  end
end
