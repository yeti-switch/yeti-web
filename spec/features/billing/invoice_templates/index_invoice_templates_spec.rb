# frozen_string_literal: true

require 'spec_helper'

describe 'Index Invoice templates', type: :feature do
  include_context :login_as_admin

  include_examples :test_index_table_exist do
    before do
      @item = create(:invoice_template)
      visit invoice_templates_path
    end
  end
end
