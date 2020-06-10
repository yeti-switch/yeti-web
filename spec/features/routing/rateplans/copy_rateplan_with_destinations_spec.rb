# frozen_string_literal: true

RSpec.describe 'Copy Rateplan action', type: :feature do
  include_context :login_as_admin

  context 'success' do
    let!(:rateplan) do
      create(:rateplan)
    end

    before do
      create_list(:destination, 2, rateplan: rateplan)
    end

    let(:new_name) { rateplan.name + '_copy' }

    before { visit rateplan_path(rateplan.id) }

    before do
      click_link('Copy with destinations', exact_text: true)
      within '#new_routing_rateplan_duplicator' do
        fill_in('Name', with: new_name)
        find('input[type=submit]').click
      end
      find('h2', text: 'Rateplans') # wait page load
    end

    context 'when "Send quality alarms to" is empty' do
      it 'creates new Rateplan with duplicated Destinations' do
        expect(rateplan.reload.destinations.count).to eq(2)
        expect(Rateplan.count).to eq(2)
        expect(Rateplan.last.destinations.count).to eq(2)
      end
    end
  end
end
