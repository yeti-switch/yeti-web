# frozen_string_literal: true

require 'spec_helper'

describe 'Index Reports Interval Cdr Schedulers', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    interval_cdr_schedulers = create_list(:interval_cdr_scheduler, 2)
    visit interval_cdr_schedulers_path
    interval_cdr_schedulers.each do |interval_cdr_scheduler|
      expect(page).to have_css('.col-id', text: interval_cdr_scheduler.id)
    end
  end
end
