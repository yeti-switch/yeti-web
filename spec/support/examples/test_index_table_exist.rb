# frozen_string_literal: true

RSpec.shared_examples :test_index_table_exist do
  it 'has record' do
    expect(page).to have_css('.resource_id_link', text: @item.id)
  end
end
