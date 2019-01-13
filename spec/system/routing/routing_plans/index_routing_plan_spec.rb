# frozen_string_literal: true

require 'spec_helper'

describe 'Index Routing Plans' do
  include_context :login_as_admin

  include_examples :test_index_table_exist do
    before do
      @item = create(:routing_plan)
      visit routing_routing_plans_path
    end
  end
end
