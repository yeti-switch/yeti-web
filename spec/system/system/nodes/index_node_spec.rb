# frozen_string_literal: true

require 'spec_helper'

describe 'Index Nodes' do
  include_context :login_as_admin

  include_examples :test_index_table_exist do
    before do
      @item = create(:node)
      visit nodes_path
    end
  end
end
