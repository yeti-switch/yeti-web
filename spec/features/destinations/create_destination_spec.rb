require 'spec_helper'

describe 'Create new Destinations', type: :feature do

  let(:admin_user) { create :admin_user }
  before { login_as(admin_user, scope: :admin_user) }

  context 'success' do

    let!(:rateplan) { create(:rateplan) }

    before { visit new_destination_path }

    include_context :fill_form, 'new_destination'

    let(:attributes) do
      {
        batch_prefix: '123',
        enabled: true,
        reject_calls: true,
        rateplan_id: rateplan.name,
        reverse_billing: true,
        initial_rate: 60,
        next_rate: 30,
        profit_control_mode_id: rateplan.profit_control_mode.name
      }
    end

    it 'creates new Dialpeers and show it' do
      page.find('input[type=submit]').click
      expect(page).to have_css('body.show.destinations')

      expect(Destination.last).to have_attributes(
        prefix: attributes[:batch_prefix],
        enabled: attributes[:enabled],
        reject_calls: attributes[:reject_calls],
        rateplan_id: rateplan.id,
        reverse_billing: true,
        initial_rate: attributes[:initial_rate],
        next_rate: attributes[:next_rate],
        profit_control_mode_id: rateplan.profit_control_mode.id
      )
    end
  end

end
