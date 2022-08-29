# frozen_string_literal: true

RSpec.describe 'Index Dialpeer', type: :feature, js: true do
  include_context :login_as_admin

  subject do
    visit dialpeers_path
    fill_filters!
  end

  let(:fill_filters!) { nil }
  let!(:dialpeers) do
    create_list(:dialpeer, 2)
  end

  it 'responds with correct rows' do
    subject
    expect(page).to have_table_row(count: dialpeers.size)
    dialpeers.each do |dialpeer|
      expect(page).to have_table_cell(column: 'ID', exact_text: dialpeer.id.to_s)
    end
  end

  context 'with filter by ID in string' do
    let(:fill_filters!) do
      within_filters do
        page.find('#q_id_input > select > option', text: 'In String').select_option
        fill_in 'Id', with: dialpeers.map(&:id).join(',')
        click_button 'Filter'
      end
    end

    before do
      create_list(:dialpeer, 2)
    end

    it 'responds with correct rows' do
      subject
      expect(page).to have_table_row(count: dialpeers.size)
      dialpeers.each do |dialpeer|
        expect(page).to have_table_cell(column: 'ID', exact_text: dialpeer.id.to_s)
      end
    end
  end
end
