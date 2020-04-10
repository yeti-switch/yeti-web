# frozen_string_literal: true

require 'spec_helper'

describe 'Index Disconnect policy codes', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    disconnect_policy_codes = create_list(:disconnect_policy_code, 2)
    visit disconnect_policy_codes_path
    disconnect_policy_codes.each do |dpc|
      expect(page).to have_css('.resource_id_link', text: dpc.id)
    end
  end
end
