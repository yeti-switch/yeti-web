require 'spec_helper'

describe 'Index Contractors', type: :feature do
  include_context :login_as_admin

  include_examples :test_index_table_exist do
    before do
      @item = create(:vendor)
      visit contractors_path
    end
  end
end
