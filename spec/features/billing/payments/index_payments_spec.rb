require 'spec_helper'

describe 'Index Payments', type: :feature do
  include_context :login_as_admin

  include_examples :test_index_table_exist do
    before do
      @item = create(:payment)
      visit payments_path
    end
  end
end
