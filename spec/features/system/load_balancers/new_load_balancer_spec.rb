# frozen_string_literal: true

require 'spec_helper'

describe 'Create new Load Balancer', type: :feature, js: true do
  include_context :login_as_admin

  before do
    visit new_load_balancer_path
  end
end
