# frozen_string_literal: true

require 'spec_helper'

describe 'Create new Routing Tag', type: :feature, js: true do
  include_context :login_as_admin

  before do
    visit new_routing_tag_path
  end
end
