require 'spec_helper'

describe 'Index Registrations', type: :feature do
  include_context :login_as_admin

  include_examples :test_index_table_exist do
    before do
      @item = create(:registration)
      visit equipment_registrations_path
    end
  end
end
