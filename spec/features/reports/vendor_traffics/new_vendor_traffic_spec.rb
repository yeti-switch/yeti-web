# frozen_string_literal: true

require 'spec_helper'

describe 'Create new Vendor Traffic', type: :feature, js: true do
  include_context :login_as_admin

  before do
    visit new_vendor_traffic_path
  end
end
