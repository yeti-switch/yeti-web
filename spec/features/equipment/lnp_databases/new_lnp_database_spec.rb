# frozen_string_literal: true

require 'spec_helper'

describe 'Create new LNP Database', type: :feature, js: true do
  include_context :login_as_admin

  before do
    visit new_lnp_database_path
  end
end
