# frozen_string_literal: true

require 'spec_helper'

describe 'Index Routeset Discriminators', type: :feature do
  include_context :login_as_admin

  include_examples :test_index_table_exist do
    before do
      @item = create(:routeset_discriminator)
      visit routing_routeset_discriminators_path
    end
  end
end
