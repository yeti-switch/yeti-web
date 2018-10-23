require 'spec_helper'

describe 'Index Rateplans', type: :feature do
  include_context :login_as_admin

  include_examples :test_index_table_exist do
    before do
      @item = create(:rateplan)
      visit rateplans_path
    end
  end
end
