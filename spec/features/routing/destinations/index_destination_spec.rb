# frozen_string_literal: true

RSpec.describe 'Index Destinations', type: :feature, js: true do
  subject do
    visit destinations_path
  end

  include_context :login_as_admin
  let!(:destinations) { create_list(:destination, 2, :filled) }

  it 'n+1 checks' do
    subject
    destinations.each do |destination|
      expect(page).to have_css('.resource_id_link', text: destination.id)
    end
  end

  context 'when filter by country and network' do
    let!(:country) { System::Country.find_by!(name: 'United States') }
    let!(:network) { create(:network, name: 'some network') }
    let!(:network_prefix) { create(:network_prefix, country: country, network: network, prefix: '123') }
    let!(:matched_record) { create(:destination, prefix: network_prefix.prefix) }
    before do
      canada = System::Country.find_by!(name: 'Canada')
      other_network = create(:network, name: 'other network')
      create(:network_prefix, country: canada, network: other_network, prefix: '23435678')
    end

    it 'selects correct network' do
      subject

      page.scroll_to('.filter_form input[type="submit"]')
      chosen_select('#q_network_prefix_country_id_eq_chosen', search: country.display_name)
      chosen_select('#q_network_prefix_network_id_eq_chosen', search: network.name, ajax: true)
      page.find('.filter_form input[type="submit"]').click

      expect(page).to have_css('.resource_id_link', text: matched_record.id)
      expect(page).to have_css('table.index_table tbody tr', count: 1)
    end
  end

  describe 'sorting' do
    subject { page.find("th.col.col-#{column} > a").click }

    context 'by Network' do
      let!(:column) { 'network' }
      let!(:destinations) { nil }
      let!(:rate_group) { FactoryBot.create(:rate_group) }
      let!(:network_type_mobile) { System::NetworkType.find_by!(name: 'Mobile') }

      let!(:afghanistan) { System::Country.find_by!(name: 'Afghanistan') }
      let!(:ukraine) { System::Country.find_by!(name: 'Ukraine') }

      let!(:afghanistan_network) { FactoryBot.create(:network, name: 'AfghanistanNet', network_type: network_type_mobile) }
      let!(:afghanistan_network_prefix) { FactoryBot.create(:network_prefix, country: afghanistan, network: afghanistan_network) }

      let!(:ukraine_network) { FactoryBot.create(:network, name: 'UkraineNetABC', network_type: network_type_mobile) }
      let!(:ukraine_network_prefix) { FactoryBot.create(:network_prefix, country: ukraine, network: ukraine_network) }

      let!(:destination_afghanistan_111_mobile) do
        destination = FactoryBot.create(:destination, rate_group: rate_group, prefix: '111')
        destination.update!(network_prefix_id: afghanistan_network_prefix.id)
        destination
      end

      let!(:destination_ukraine_999_mobile) do
        destination = FactoryBot.create(:destination, rate_group: rate_group, prefix: '999')
        destination.update!(network_prefix_id: ukraine_network_prefix.id)
        destination
      end

      context 'ASC' do
        before { visit destinations_path(order: 'networks.name_desc') }

        it 'should sorted by ASC' do
          subject

          within_table_for do
            expect(page).to have_table_row(count: 2)
            within_table_row(index: 0) do
              expect(page).to have_table_cell(column: 'ID', exact_text: destination_afghanistan_111_mobile.id.to_s)
            end
            within_table_row(index: 1) do
              expect(page).to have_table_cell(column: 'ID', exact_text: destination_ukraine_999_mobile.id.to_s)
            end
          end
        end
      end

      context 'DESC' do
        before { visit destinations_path(order: 'networks.name_asc') }

        it 'should sorted by DESC' do
          subject

          within_table_for do
            expect(page).to have_table_row(count: 2)
            within_table_row(index: 0) do
              expect(page).to have_table_cell(column: 'ID', exact_text: destination_ukraine_999_mobile.id.to_s)
            end
            within_table_row(index: 1) do
              expect(page).to have_table_cell(column: 'ID', exact_text: destination_afghanistan_111_mobile.id.to_s)
            end
          end
        end
      end
    end
  end
end
