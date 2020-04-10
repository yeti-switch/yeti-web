# frozen_string_literal: true

require 'spec_helper'

describe 'Index Customer Auths', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    customers_auths = create_list(:customers_auth, 2, :filled)
    visit customers_auths_path
    customers_auths.each do |customers_auth|
      expect(page).to have_css('.resource_id_link', text: customers_auth.id)
    end
  end
end
