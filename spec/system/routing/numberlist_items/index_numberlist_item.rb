# frozen_string_literal: true

require 'spec_helper'

describe 'Index Numberlist Item' do
  include_context :login_as_admin

  include_examples :test_index_table_exist do
    before do
      @item = create(:numberlist_item)
      visit routing_numberlist_items_path
    end
  end
end
