# frozen_string_literal: true

require 'spec_helper'

describe 'Create new Disconnect Policy Code', type: :feature, js: true do
  include_context :login_as_admin

  before do
    visit new_disconnect_policy_code_path
  end
end
