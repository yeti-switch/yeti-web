# frozen_string_literal: true

require 'spec_helper'

describe 'Index Numberlists' do
  include_context :login_as_admin

  include_examples :test_index_table_exist do
    before do
      @item = create(:numberlist)
      visit numberlists_path
    end
  end
end
