# frozen_string_literal: true

module FeatureActiveAdminHelper
  def wait_index_js_table_render
    expect(page).to have_selector('table.index_table.index-js-table-loaded')
  end
end
