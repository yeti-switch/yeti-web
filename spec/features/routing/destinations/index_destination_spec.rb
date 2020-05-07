# frozen_string_literal: true

require 'spec_helper'

describe 'Index Destinations', type: :feature, js: true do
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
    let!(:country) { create(:country, name: 'United Stated', iso2: 'US') }
    let!(:network) { create(:network, name: 'some network') }
    let!(:network_prefix) { create(:network_prefix, country: country, network: network, prefix: '123') }
    let!(:matched_record) { create(:destination, prefix: network_prefix.prefix) }
    before do
      canada = create(:country, name: 'Canada', iso2: 'CA')
      other_network = create(:network, name: 'other network')
      create(:network_prefix, country: canada, network: other_network, prefix: '23435678')
    end

    it 'selects correct network' do
      subject

      scroll_to_element('.filter_form input[type="submit"]')
      chosen_select('#q_network_prefix_country_id_eq_chosen', search: country.display_name)
      chosen_select('#q_network_prefix_network_id_eq_chosen', search: network.name)
      page.find('.filter_form input[type="submit"]').click

      expect(page).to have_css('.resource_id_link', text: matched_record.id)
      expect(page).to have_css('table.index_table tbody tr', count: 1)
    end
  end
end
