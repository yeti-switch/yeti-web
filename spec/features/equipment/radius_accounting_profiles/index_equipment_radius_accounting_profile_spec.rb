# frozen_string_literal: true

require 'spec_helper'

describe 'Index Equipment Radius Accounting Profiles', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    eq_radius_accounting_profiles = create_list(:accounting_profile, 2, :filled)
    visit equipment_radius_accounting_profiles_path
    eq_radius_accounting_profiles.each do |er_acc_profile|
      expect(page).to have_css('.resource_id_link', text: er_acc_profile.id)
    end
  end
end
