# frozen_string_literal: true

RSpec.describe 'Index Routing Dialpeer Next Rates', type: :feature, js: true do
  subject do
    visit page_url
  end

  include_context :login_as_admin

  let!(:dialpeer_next_rates) do
    create_list(:dialpeer_next_rate, 2)
  end
  let(:page_url) do
    dialpeer_next_rates_path
  end

  it 'n+1 checks' do
    subject
    expect(page).to have_table_row(count: dialpeer_next_rates.size)
    dialpeer_next_rates.each do |dialpeer_next_rate|
      expect(page).to have_table_cell(column: 'Id', exact_text: dialpeer_next_rate.id.to_s)
    end
  end

  context 'when nested in dialpeer' do
    let!(:dialpeer) do
      FactoryBot.create(:dialpeer)
    end
    let!(:dialpeer_next_rates) do
      create_list(:dialpeer_next_rate, 2, dialpeer: dialpeer)
    end
    let(:page_url) do
      dialpeer_dialpeer_next_rates_path(dialpeer_id: dialpeer.id)
    end

    before do
      FactoryBot.create(:dialpeer_next_rate)
    end

    it 'n+1 checks' do
      subject
      expect(page).to have_table_row(count: dialpeer_next_rates.size)
      dialpeer_next_rates.each do |dialpeer_next_rate|
        expect(page).to have_table_cell(column: 'Id', exact_text: dialpeer_next_rate.id.to_s)
      end
    end
  end
end
