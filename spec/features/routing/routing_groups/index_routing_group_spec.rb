# frozen_string_literal: true

require 'spec_helper'

describe 'Index Routing Groups', type: :feature do
  include_context :login_as_admin

  include_examples :test_index_table_exist do
    before do
      @item = create(:routing_group)
      visit routing_groups_path
    end
  end
end
