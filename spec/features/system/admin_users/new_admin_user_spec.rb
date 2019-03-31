# frozen_string_literal: true

require 'spec_helper'

describe 'Create new Admin User', type: :feature, js: true do
  include_context :login_as_admin

  before do
    visit new_admin_user_path
  end
end
