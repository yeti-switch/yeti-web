# frozen_string_literal: true

require 'spec_helper'

describe 'Create new Smtp Connection', type: :feature, js: true do
  include_context :login_as_admin

  before do
    visit new_smtp_connection_path
  end
end
