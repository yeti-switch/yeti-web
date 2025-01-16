# frozen_string_literal: true

RSpec.describe 'Index System Network Types', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    system_network_types = create_list(:network_type, 2, :filled)
    visit system_network_types_path
    system_network_types.each do |system_network_type|
      within_table_row(id: system_network_type.id) do
        expect(page).to have_table_cell(column: 'Sorting priority', exact_text: system_network_type.sorting_priority.to_s)
      end
    end
  end
end
