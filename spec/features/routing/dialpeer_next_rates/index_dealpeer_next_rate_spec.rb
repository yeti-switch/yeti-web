# frozen_string_literal: true

require 'spec_helper'

describe 'Index Routing Dialpeer Next Rates', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    dialpeer_next_rates = create_list(:dialpeer_next_rate, 2)
    visit dialpeer_next_rates_path
    dialpeer_next_rates.each do |dialpeer_next_rate|
      expect(page).to have_css('.col-id', text: dialpeer_next_rate.id)
    end
  end
end
