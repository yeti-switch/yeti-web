# frozen_string_literal: true

require 'spec_helper'

describe 'Create new Numberlist Item', type: :feature, js: true do
  include_context :login_as_admin

  before do
    visit new_numberlist_item_path
  end
end
