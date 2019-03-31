# frozen_string_literal: true

require 'spec_helper'

describe 'Create new Customer Traffic Scheduler', type: :feature, js: true do
  include_context :login_as_admin

  before do
    visit new_customer_traffic_scheduler_path
  end
end
