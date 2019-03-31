# frozen_string_literal: true

require 'spec_helper'

describe 'Create new Network Prefix', type: :feature, js: true do
  include_context :login_as_admin

  before do
    visit new_network_prefix_path
  end
end
