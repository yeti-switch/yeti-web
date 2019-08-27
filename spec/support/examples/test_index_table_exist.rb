# frozen_string_literal: true

RSpec.shared_examples :test_index_table_exist do |id_css = '.resource_id_link'|
  it 'has record' do
    expect(page).to have_css(id_css, text: @item.id)
  end
end
