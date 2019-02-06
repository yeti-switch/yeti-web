# frozen_string_literal: true

require 'spec_helper'

describe 'Create new Gateway group', type: :feature, js: true do
  include_context :login_as_admin

  before do
    @vendor = create(:vendor)
    visit new_gateway_group_path
  end

  include_context :fill_form, 'new_gateway_group' do
    let(:attributes) do
      {
          name: 'GW group',
          vendor_id: lambda {
            chosen_pick('#gateway_group_vendor_id+div', text: @vendor.name)
          },
          prefer_same_pop: true
      }
    end

    it 'creates new gateway group succesfully' do
      click_on_submit

      expect(page).to have_css('.flash_notice', text: 'Gateway group was successfully created.')

      expect(GatewayGroup.last).to have_attributes(
                                  name: attributes[:name],
                                  vendor_id: @vendor.id,
                                  prefer_same_pop: attributes[:prefer_same_pop]
                              )
    end
  end
end
