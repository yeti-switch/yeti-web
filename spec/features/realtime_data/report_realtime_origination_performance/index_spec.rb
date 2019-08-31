# frozen_string_literal: true

require 'spec_helper'

describe 'Report Realtime Origination Performance', type: :feature do
  include_context :login_as_admin

  let!(:customers_auth) { FactoryGirl.create(:customers_auth) }
  before do
    FactoryGirl.create_list(:cdr, 5, customer_auth: customers_auth, time_start: 28.hours.ago.utc)
    visit report_realtime_origination_performances_path(q: { time_interval_eq: 1.day })
  end

  it 'has one record' do
    expect(page).to have_css('table.index_table tbody tr', count: 1)
    expect(page).to have_css('.col-customer_auth', text: customers_auth.display_name)
    expect(page).to_not have_css('flash-warning')
    expect(page).to_not have_css('flash-error')
  end
end
