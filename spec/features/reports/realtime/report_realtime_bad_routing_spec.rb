# frozen_string_literal: true

RSpec.describe 'Index Report Realtime Bad Routing', :js do
  include_context :login_as_admin
  after { Report::Realtime::BadRouting.delete_all }
  let!(:customer) { create :customer }
  let!(:disconnect_initiator) { create :disconnect_initiator }
  let!(:customer_auth) { create :customers_auth, customer: customer }
  let!(:rateplan) { create :rateplan }
  let!(:routing_plan) { create :routing_plan }

  let!(:bad_routing) {
    FactoryBot.create(:bad_routing, :with_id_and_uuid, time_start: 65.seconds.ago,
                                                       disconnect_initiator: disconnect_initiator,
                                                       customer_auth: customer_auth,
                                                       customer_id: customer.id,
                                                       rateplan: rateplan,
                                                       routing_plan: routing_plan,
                                                       internal_disconnect_code: 500,
                                                       internal_disconnect_reason: 'Internal Error')
  }

  it 'n+1 checks' do
    visit report_realtime_bad_routings_path
    expect(page).to have_http_status(:ok)
  end
end
