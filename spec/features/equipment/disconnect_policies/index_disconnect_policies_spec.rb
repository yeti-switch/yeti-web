require 'spec_helper'

describe 'Index Disconnect policies', type: :feature do
  include_context :login_as_admin

  include_examples :test_index_table_exist do
    before do
      @item = create(:disconnect_policy)
      visit disconnect_policies_path
    end
  end
end
