# frozen_string_literal: true

RSpec.describe 'Index System Lua Scripts', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    system_lua_scripts = create_list(:lua_script, 2, :filled)
    visit system_lua_scripts_path
    system_lua_scripts.each do |system_lua_script|
      expect(page).to have_css('.resource_id_link', text: system_lua_script.id)
    end
  end
end
