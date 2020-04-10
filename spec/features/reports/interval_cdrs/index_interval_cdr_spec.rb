# frozen_string_literal: true

require 'spec_helper'

describe 'Index Reports Interval cdr', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    interval_cdrs = create_list(:interval_cdr, 2)
    visit report_interval_cdrs_path
    interval_cdrs.each do |interval_cdr|
      expect(page).to have_css('.col-id', text: interval_cdr.id)
    end
  end
end
