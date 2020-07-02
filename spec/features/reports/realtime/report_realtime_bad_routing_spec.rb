# frozen_string_literal: true

RSpec.describe 'Index Report Realtime Bad Routing' do
  include_context :login_as_admin

  it 'should have records' do
    bad_routings = FactoryBot.create_list :bad_routing, 2
    visit report_realtime_bad_routings_path
    bad_routings.each do |routing|
      expect(page).to have_css '.col-customer_auth', text: routing.customer_auth.display_name
    end
  end
end
