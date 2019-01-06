require 'spec_helper'

describe 'Index Destinations', type: :feature do
  include_context :login_as_admin

  include_examples :test_index_table_exist do
    before do
      @item = create(:destination)
      visit destinations_path
    end
  end
end
