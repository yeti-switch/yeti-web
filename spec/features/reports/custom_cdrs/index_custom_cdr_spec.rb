# frozen_string_literal: true

require 'spec_helper'

describe 'Index Reports Custom Cdrs', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    custom_cdrs = create_list(:custom_cdr, 2)
    visit custom_cdrs_path
    custom_cdrs.each do |custom_cdr|
      expect(page).to have_css('.col-id', text: custom_cdr.id)
    end
  end
end
