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
      page.within('.filter_form') do
        fill_in_tom_select('Country', with: country.display_name)
        fill_in_tom_select('Network', with: network.name, ajax: true)
        page.find('input[type="submit"]').click
      end

      expect(page).to have_css('.resource_id_link', text: matched_record.id)
      expect(page).to have_css('table.index_table tbody tr', count: 1)
    end
  end
end
