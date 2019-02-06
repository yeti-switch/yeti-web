# frozen_string_literal: true

require 'spec_helper'

describe 'Create new Gateway', type: :feature, js: true do
  include_context :login_as_admin

  before do
    @vendor = create(:vendor)
    visit new_gateway_path
  end

  include_context :fill_form, 'new_gateway' do
    let(:attributes) do
      {
          name: 'vendor GW',
          contractor_id: lambda {
            chosen_pick('#gateway_contractor_id+div', text: @vendor.name)
          },
          allow_termination: true,
          host: lambda {
            page.find('.tabs.ui-tabs li.ui-tabs-tab a', text: 'Signaling').click
          }
      }
    end

    it 'creates new gateway succesfully' do
      click_on_submit

      expect(page).to have_css('.flash_notice', text: 'Gateway was successfully created.')

      expect(Gateway.last).to have_attributes(
                                       name: attributes[:name],
                                       contractor_id: @vendor.id,
                                       host: attributes[:host]
                                   )
    end
  end
end
