# frozen_string_literal: true

require 'spec_helper'

describe 'Create new Lua Script', type: :feature, js: true do
  subject do
    aa_form.submit
  end

  active_admin_form_for System::LuaScript, 'new'
  include_context :login_as_admin

  before do
    visit new_system_lua_script_path

    aa_form.set_text 'Name', 'test'
    aa_form.set_text 'Source', 'print("rspec")'
  end

  it 'creates record' do
    subject
    record = System::LuaScript.last
    expect(record).to be_present
    expect(record).to have_attributes(
      name: 'test',
      source: 'print("rspec")'
    )
  end

  include_examples :changes_records_qty_of, System::LuaScript, by: 1
  include_examples :shows_flash_message, :notice, 'Lua script was successfully created.'
end
