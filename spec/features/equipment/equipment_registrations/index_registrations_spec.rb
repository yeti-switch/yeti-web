# frozen_string_literal: true

require 'spec_helper'

describe 'Index Registrations', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    equipment_registrations = create_list(:registration, 2, :filled)
    visit equipment_registrations_path
    equipment_registrations.each do |registration|
      expect(page).to have_css('.resource_id_link', text: registration.id)
    end
  end
end
