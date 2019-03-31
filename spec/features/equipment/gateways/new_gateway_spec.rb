# frozen_string_literal: true

require 'spec_helper'

describe 'Create new Gateway', type: :feature, js: true do
  include_context :login_as_admin

  before do
    visit new_gateway_path
  end
end
