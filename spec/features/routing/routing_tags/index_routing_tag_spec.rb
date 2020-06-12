# frozen_string_literal: true

RSpec.describe 'Index Routing Routing Tag', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    routing_routing_tags = create_list(:routing_tag, 2)
    visit routing_routing_tags_path
    routing_routing_tags.each do |routing_routing_tag|
      expect(page).to have_css('.resource_id_link', text: routing_routing_tag.id)
    end
  end
end
