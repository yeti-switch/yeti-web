# frozen_string_literal: true

RSpec.describe 'Index Routing Lnp Caches', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    lnp_caches = create_list(:lnp_cache, 2)
    visit lnp_caches_path
    lnp_caches.each do |lnp_cache|
      expect(page).to have_css('.resource_id_link', text: lnp_cache.id)
    end
  end
end
