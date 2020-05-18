# frozen_string_literal: true

require 'spec_helper'

describe 'Report Realtime Termination Distribution', type: :feature do
  include_context :login_as_admin

  let!(:vendor) { FactoryBot.create(:vendor) }
  before do
    Cdr::Cdr.destroy_all
    FactoryBot.create_list(:cdr, 5, vendor: vendor)
    visit report_realtime_termination_distributions_path(q: { time_interval_eq: 1.day })
  end

  it 'has one record' do
    expect(page).to have_css('table.index_table tbody tr', count: 1)
    expect(page).to have_css('.col-vendor', text: vendor.display_name)
    expect(page).to_not have_css('flash-warning')
    expect(page).to_not have_css('flash-error')
  end
end
