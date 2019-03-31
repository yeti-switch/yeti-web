# frozen_string_literal: true

require 'spec_helper'

describe 'Create new Rateplan Duplicator', type: :feature, js: true do
  include_context :login_as_admin

  before do
    visit new_rateplan_duplicator_path
  end
end
