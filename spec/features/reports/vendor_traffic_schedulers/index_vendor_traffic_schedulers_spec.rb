# frozen_string_literal: true

RSpec.describe 'Index Reports Vendor Traffic Schedulers', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    vendor_traffic_schedulers = create_list(:vendor_traffic_scheduler, 2)
    visit vendor_traffic_schedulers_path
    vendor_traffic_schedulers.each do |vendor_traffic_scheduler|
      expect(page).to have_css('.col-id', text: vendor_traffic_scheduler.id)
    end
  end
end
