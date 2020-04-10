# frozen_string_literal: true

require 'spec_helper'

describe 'Index Radius Auth Profiles', type: :feature do
  include_context :login_as_admin
  let!(:customers_auth) { create(:customers_auth) }
  it 'n+1 checks' do
    equipment_radius_auth_profiles = create_list(:auth_profile, 2, :filled)
    visit equipment_radius_auth_profiles_path
    equipment_radius_auth_profiles.each do |equipment_radius_auth_profile|
      expect(page).to have_css('.resource_id_link', text: equipment_radius_auth_profile.id)
    end
  end
end
