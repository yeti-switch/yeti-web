# frozen_string_literal: true

require 'spec_helper'

describe 'Index Customer Auths' do
  include_context :login_as_admin

  include_examples :test_index_table_exist do
    before do
      @item = create(:customers_auth)
      visit customers_auths_path
    end
  end
end
