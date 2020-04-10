# frozen_string_literal: true

require 'spec_helper'

describe 'Index Routing area prefix', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    routing_area_prefixes = create_list(:area_prefix, 2)
    visit routing_area_prefixes_path
    routing_area_prefixes.each do |routing_area_prefix|
      expect(page).to have_css('.resource_id_link', text: routing_area_prefix.id)
    end
  end
end
