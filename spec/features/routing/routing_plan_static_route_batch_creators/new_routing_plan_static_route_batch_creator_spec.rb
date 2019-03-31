# frozen_string_literal: true

require 'spec_helper'

describe 'Create new Routing Plan Static Route Batch Creator', type: :feature, js: true do
  include_context :login_as_admin

  before do
    visit new_routing_plan_static_route_batch_creator_path
  end
end
