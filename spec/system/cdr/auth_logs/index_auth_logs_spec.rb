# frozen_string_literal: true

require 'spec_helper'

describe 'Auth Logs Index' do
  include_context :login_as_admin

  include_examples :test_index_table_exist do
    before do
      @item = create(:auth_log)
      visit auth_logs_path
    end
  end
end
