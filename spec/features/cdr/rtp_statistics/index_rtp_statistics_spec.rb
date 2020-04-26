# frozen_string_literal: true

require 'spec_helper'

describe 'RTP statistics index', type: :feature do
  include_context :login_as_admin

  include_examples :test_index_table_exist do
    before do
      @item = create(:rtp_statistic)
      visit rtp_statistics_path
    end
  end
end