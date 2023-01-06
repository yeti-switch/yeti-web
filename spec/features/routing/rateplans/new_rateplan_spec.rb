# frozen_string_literal: true

RSpec.describe 'Create new Rateplan', type: :feature, js: true do
  include_context :login_as_admin

  before do
    visit new_routing_rateplan_path
  end

  include_context :fill_form, 'new_routing_rateplan' do
    let(:attributes) do
      {
        name: 'test rateplan',
        profit_control_mode_id: Routing::RateProfitControlMode::MODES[Routing::RateProfitControlMode::MODE_PER_CALL]
      }
    end

    it 'creates new rateplan succesfully' do
      click_on_submit
      expect(page).to have_css('.flash_notice', text: 'Rateplan was successfully created.')

      expect(Routing::Rateplan.last).to have_attributes(
        name: attributes[:name],
        profit_control_mode_id: Routing::RateProfitControlMode::MODE_PER_CALL
      )
    end
  end
end
