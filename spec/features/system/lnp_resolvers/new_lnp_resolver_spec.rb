# frozen_string_literal: true

require 'spec_helper'

describe 'Create new Lnp Resolver', type: :feature, js: true do
  include_context :login_as_admin

  before do
    visit new_lnp_resolver_path
  end
end
