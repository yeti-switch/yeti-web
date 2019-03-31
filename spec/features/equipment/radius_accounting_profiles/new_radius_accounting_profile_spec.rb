# frozen_string_literal: true

require 'spec_helper'

describe 'Create new Radius Accounting Profile', type: :feature, js: true do
  include_context :login_as_admin

  before do
    visit new_radius_accounting_profile_path
  end
end
