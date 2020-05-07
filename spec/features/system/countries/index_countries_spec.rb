# frozen_string_literal: true

require 'spec_helper'

describe 'Index System Countries', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    countries = create_list(:country, 2, :uniq_name)
    visit system_countries_path
    countries.each do |country|
      expect(page).to have_css('.resource_id_link', text: country.id)
    end
  end
end
