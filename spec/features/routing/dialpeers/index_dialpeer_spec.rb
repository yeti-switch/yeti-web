# frozen_string_literal: true

RSpec.describe 'Index Dialpeer', type: :feature, js: true do
  include_context :login_as_admin

  subject do
    visit dialpeers_path(index_params)
    fill_filters!
  end

  let(:index_params) { nil }
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
        fill_in_filter_type_tom_select 'Id', with: 'In string'
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

  context 'with expired scope' do
    let(:index_params) { { scope: 'expired' } }
    let!(:expired_dialpeers) do
      create_list(:dialpeer, 3, valid_from: 1.day.ago, valid_till: 1.second.ago)
    end

    before do
      create(:dialpeer, valid_from: 1.day.ago, valid_till: 1.minute.from_now)
    end

    it 'responds with correct rows' do
      subject
      expect(page).to have_table_row(count: expired_dialpeers.size)
      expired_dialpeers.each do |dialpeer|
        expect(page).to have_table_cell(column: 'ID', exact_text: dialpeer.id.to_s)
      end
    end
  end
end
