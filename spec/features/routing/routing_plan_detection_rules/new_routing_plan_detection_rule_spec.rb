# frozen_string_literal: true

require 'spec_helper'

describe 'Create new Routing Plan Detection Rule', type: :feature, js: true do
  include_context :login_as_admin

  before do
    visit new_routing_plan_detection_rule_path
  end
end
