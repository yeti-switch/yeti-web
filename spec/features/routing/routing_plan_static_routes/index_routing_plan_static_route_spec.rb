# frozen_string_literal: true

RSpec.describe 'Index Routing Plan Static Route', :js do
  include_context :login_as_admin

  it 'n+1 checks' do
    static_routes = create_list :static_route, 2, :filled
    visit static_routes_path
    static_routes.each do |static_route|
      expect(page).to have_css('.resource_id_link', text: static_route.id)
    end
  end
end
