# frozen_string_literal: true

require 'spec_helper'

describe 'Create new Radius Auth Profile', type: :feature, js: true do
  include_context :login_as_admin

  before do
    visit new_radius_auth_profile_path
  end
end
