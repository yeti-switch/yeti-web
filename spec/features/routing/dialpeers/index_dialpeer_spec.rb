# frozen_string_literal: true

require 'spec_helper'

describe 'Index Dialpeer', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    dialpeers = create_list(:dialpeer, 2)
    visit dialpeers_path
    dialpeers.each do |dialpeer|
      expect(page).to have_css('.resource_id_link', text: dialpeer.id)
    end
  end
end
