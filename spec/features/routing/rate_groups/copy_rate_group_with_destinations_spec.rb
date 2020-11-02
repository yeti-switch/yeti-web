# frozen_string_literal: true

RSpec.describe 'Copy RateGroup action', type: :feature do
  include_context :login_as_admin

  context 'success' do
    let!(:rate_group) do
      create(:rate_group)
    end

    before do
      create_list(:destination, 2, rate_group: rate_group)
    end

    let(:new_name) { rate_group.name + '_copy' }

    before { visit routing_rate_group_path(rate_group.id) }

    before do
      click_link('Copy with destinations', exact_text: true)
      within '#new_routing_rate_group_duplicator' do
        fill_in('Name', with: new_name)
        find('input[type=submit]').click
      end
      find('h2', text: 'Routing Rate Groups') # wait page load
    end

    context 'when "Send quality alarms to" is empty' do
      it 'creates new RateGroup with duplicated Destinations' do
        expect(rate_group.reload.destinations.count).to eq(2)
        expect(Routing::RateGroup.count).to eq(2)
        expect(Routing::RateGroup.last.destinations.count).to eq(2)
      end
    end
  end
end
