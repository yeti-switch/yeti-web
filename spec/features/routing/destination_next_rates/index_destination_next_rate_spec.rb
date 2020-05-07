# frozen_string_literal: true

require 'spec_helper'

describe 'Index Routing Destination Next Rates', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    destination_next_rates = create_list(:destination_next_rate, 2)
    visit destination_next_rates_path
    destination_next_rates.each do |dest_next_rate|
      expect(page).to have_css('.col-id', text: dest_next_rate.id)
    end
  end
end
