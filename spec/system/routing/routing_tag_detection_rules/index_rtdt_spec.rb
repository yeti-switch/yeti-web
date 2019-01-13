# frozen_string_literal: true

require 'spec_helper'

describe 'Index Routing Tag Detection Rules' do
  include_context :login_as_admin

  include_examples :test_index_table_exist do
    before do
      @item = create(:routing_tag_detection_rule)
      visit routing_routing_tag_detection_rules_path
    end
  end
end
