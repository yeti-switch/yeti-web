# frozen_string_literal: true

require 'spec_helper'

describe 'Create new Routing Group Duplicator', type: :feature, js: true do
  include_context :login_as_admin

  before do
    visit new_routing_group_duplicator_path
  end
end
