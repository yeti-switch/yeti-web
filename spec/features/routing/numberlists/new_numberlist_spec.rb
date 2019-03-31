# frozen_string_literal: true

require 'spec_helper'

describe 'Create new Numberlist', type: :feature, js: true do
  include_context :login_as_admin

  before do
    visit new_numberlist_path
  end
end
