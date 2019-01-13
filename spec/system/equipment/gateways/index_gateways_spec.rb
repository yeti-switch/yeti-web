# frozen_string_literal: true

require 'spec_helper'

describe 'Index Gateways' do
  include_context :login_as_admin

  include_examples :test_index_table_exist do
    before do
      @item = create(:gateway)
      visit gateways_path
    end
  end
end
