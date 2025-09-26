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
        fill_in_chosen('#q_id_input > select', with: 'In string', no_search: true, selector: true)
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

  describe 'sorting' do
    subject { page.find("th.col.col-#{column} > a").click }

    context 'by Network' do
      let!(:column) { 'network' }
      let!(:dialpeers) { nil }
      let!(:network_type_mobile) { System::NetworkType.find_by!(name: 'Mobile') }

      let!(:afghanistan) { System::Country.find_by!(name: 'Afghanistan') }
      let!(:ukraine) { System::Country.find_by!(name: 'Ukraine') }

      let!(:afghanistan_network) { FactoryBot.create(:network, name: 'AfghanistanNet', network_type: network_type_mobile) }
      let!(:afghanistan_network_prefix) { FactoryBot.create(:network_prefix, country: afghanistan, network: afghanistan_network) }

      let!(:ukraine_network) { FactoryBot.create(:network, name: 'UkraineNetABC', network_type: network_type_mobile) }
      let!(:ukraine_network_prefix) { FactoryBot.create(:network_prefix, country: ukraine, network: ukraine_network) }

      let!(:dialpeer_afghanistan_111_mobile) do
        dialpeer = FactoryBot.create(:dialpeer, prefix: '111')
        dialpeer.update!(network_prefix_id: afghanistan_network_prefix.id)
        dialpeer
      end

      let!(:dialpeer_ukraine_999_mobile) do
        dialpeer = FactoryBot.create(:dialpeer, prefix: '999')
        dialpeer.update!(network_prefix_id: ukraine_network_prefix.id)
        dialpeer
      end

      context 'ASC' do
        before { visit dialpeers_path(order: 'networks.name_desc') }

        it 'should sorted by ASC' do
          subject

          within_table_for do
            expect(page).to have_table_row(count: 2)
            within_table_row(index: 0) do
              expect(page).to have_table_cell(column: 'ID', exact_text: dialpeer_afghanistan_111_mobile.id.to_s)
            end
            within_table_row(index: 1) do
              expect(page).to have_table_cell(column: 'ID', exact_text: dialpeer_ukraine_999_mobile.id.to_s)
            end
          end
        end
      end

      context 'DESC' do
        before { visit dialpeers_path(order: 'networks.name_asc') }

        it 'should sorted by DESC' do
          subject

          within_table_for do
            expect(page).to have_table_row(count: 2)
            within_table_row(index: 0) do
              expect(page).to have_table_cell(column: 'ID', exact_text: dialpeer_ukraine_999_mobile.id.to_s)
            end
            within_table_row(index: 1) do
              expect(page).to have_table_cell(column: 'ID', exact_text: dialpeer_afghanistan_111_mobile.id.to_s)
            end
          end
        end
      end
    end
  end
end
