# frozen_string_literal: true

RSpec.describe 'Index Routing Area', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    routing_areas = create_list(:area, 2, :filled)
    visit routing_areas_path
    routing_areas.each do |routing_area|
      expect(page).to have_css('.resource_id_link', text: routing_area.id)
    end
  end
end
