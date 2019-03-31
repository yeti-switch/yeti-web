# frozen_string_literal: true

require 'spec_helper'

describe 'Create new Routing Plan Lnp Rule', type: :feature, js: true do
  include_context :login_as_admin

  before do
    visit new_routing_plan_lnp_rule_path
  end
end
