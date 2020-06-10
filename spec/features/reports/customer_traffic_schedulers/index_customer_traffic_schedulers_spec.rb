# frozen_string_literal: true

RSpec.describe 'Index Reports Customer Traffic Schedulers', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    customer_traffic_schedulers = create_list(:customer_traffic_scheduler, 2)
    visit customer_traffic_schedulers_path
    customer_traffic_schedulers.each do |traffic_scheduler|
      expect(page).to have_css('.col-id', text: traffic_scheduler.id)
    end
  end
end
