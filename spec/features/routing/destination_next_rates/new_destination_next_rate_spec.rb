# frozen_string_literal: true

require 'spec_helper'

describe 'Create new Destination Next Rate', type: :feature, js: true do
  include_context :login_as_admin

  before do
    visit new_destination_next_rate_path
  end
end
