require 'spec_helper'

describe 'Index Invoices', type: :feature do
  include_context :login_as_admin

  include_examples :test_index_table_exist do
    before do
      @item = create(:invoice, :manual)
      visit invoices_path
    end
  end
end
