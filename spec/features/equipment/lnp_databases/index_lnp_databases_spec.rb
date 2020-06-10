# frozen_string_literal: true

RSpec.describe 'Index lnp Databases', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    lnp_databases = create_list(:lnp_database, 2, :thinq)
    visit lnp_databases_path
    lnp_databases.each do |lnp_database|
      expect(page).to have_css('.resource_id_link', text: lnp_database.id)
    end
  end
end
