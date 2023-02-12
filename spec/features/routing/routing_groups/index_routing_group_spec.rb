# frozen_string_literal: true

RSpec.describe 'Index Routing Groups', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    routing_groups = create_list(:routing_group, 2, :with_dialpeers)
    visit routing_routing_groups_path
    routing_groups.each do |routing_group|
      expect(page).to have_css('.resource_id_link', text: routing_group.id)
    end
  end
end
