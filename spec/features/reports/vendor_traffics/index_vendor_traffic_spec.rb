# frozen_string_literal: true

require 'spec_helper'

describe 'Index Reports Vendor Traffics', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    vendor_traffics = create_list(:vendor_traffic, 2)
    visit vendor_traffics_path
    vendor_traffics.each do |vendor_traffic|
      expect(page).to have_css('.col-id', text: vendor_traffic.id)
    end
  end
end
