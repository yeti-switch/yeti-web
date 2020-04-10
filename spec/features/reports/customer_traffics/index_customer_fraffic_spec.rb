# frozen_string_literal: true

require 'spec_helper'

describe 'Index Reports Customer Traffics', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    customer_traffics = create_list(:customer_traffic, 2)
    visit customer_traffics_path
    customer_traffics.each do |customer_traffic|
      expect(page).to have_css('.col-id', text: customer_traffic.id)
    end
  end
end
