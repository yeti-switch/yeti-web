# frozen_string_literal: true

require 'spec_helper'

describe 'Create new Rateplan', type: :feature, js: true do
  include_context :login_as_admin

  before do
    visit new_rateplan_path
  end

  include_context :fill_form, 'new_rateplan' do
    let(:attributes) do
      {
        name: 'test rateplan',
        profit_control_mode_id: 'per call'
      }
    end

    it 'creates new rateplan succesfully' do
      click_on_submit
      expect(page).to have_css('.flash_notice', text: 'Rateplan was successfully created.')

      expect(Rateplan.last).to have_attributes(
        name: attributes[:name],
        profit_control_mode_id: 2 # TODO: fix it
      )
    end
  end
end
