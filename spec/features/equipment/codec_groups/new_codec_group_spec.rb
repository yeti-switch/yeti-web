# frozen_string_literal: true

require 'spec_helper'

describe 'Create new Codec Group', type: :feature, js: true do
  include_context :login_as_admin

  before do
    visit new_codec_group_path
  end
end
