# frozen_string_literal: true

require 'spec_helper'

describe 'Index Api Accesses', type: :feature do
  include_context :login_as_admin

  include_examples :test_index_table_exist do
    before do
      @item = create(:api_access)
      visit api_accesses_path
    end
  end
end
