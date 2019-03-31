# frozen_string_literal: true

require 'spec_helper'

describe 'Create new Lua Script', type: :feature, js: true do
  include_context :login_as_admin

  before do
    visit new_lua_script_path
  end
end
