# frozen_string_literal: true

RSpec.describe 'Create new Routing Plan Static Route Batch Creator', type: :feature, js: true do
  subject do
    click_submit('Create Routing plan static route batch creator')
  end

  include_context :login_as_admin

  let!(:vendor_1) { FactoryBot.create(:vendor, name: 'Vendor 1') }
  let!(:vendor_2) { FactoryBot.create(:vendor, name: 'Vendor 2') }
  let!(:routing_plan) { FactoryBot.create(:routing_plan, :with_static_routes) }
  before do
    FactoryBot.create(:routing_plan)
    FactoryBot.create(:routing_plan, :with_static_routes)
    FactoryBot.create(:vendor)

    visit new_routing_plan_static_route_batch_creator_path

    fill_in_tom_select 'Routing plan', with: routing_plan.display_name, search: true
    fill_in 'Prefixes', with: '26327,34205'
    # Inject value+text via the tom-select API: the ajax search chain races the
    # re-fetch from the second selection on this multiple select and drops a chip
    # under CI load. Order sets priority: vendor_2 -> 100, vendor_1 -> 95.
    select_tom_select_by_value 'Vendors', { vendor_2.id => vendor_2.display_name, vendor_1.id => vendor_1.display_name }
    # Chips are added synchronously; keep the barrier as a pre-submit guard.
    expect(page).to have_field_tom_select('Vendors', with: vendor_2.display_name, exact: false)
    expect(page).to have_field_tom_select('Vendors', with: vendor_1.display_name, exact: false)
  end

  it 'creates record' do
    expect {
      subject
      expect(page).to have_flash_message('Routing plan static route batch creator was successfully created.', type: :notice)
    }.to change { Routing::RoutingPlanStaticRoute.count }.by(4)

    records = Routing::RoutingPlanStaticRoute.last(4)
    expect(records.size).to eq(4)
    network_prefix_26327 = System::NetworkPrefix.longest_match('26327')
    network_prefix_34205 = System::NetworkPrefix.longest_match('34205')
    expect(records.first).to have_attributes(
      routing_plan_id: routing_plan.id,
      prefix: '26327',
      vendor_id: vendor_2.id,
      priority: 100,
      weight: 100,
      network_prefix_id: network_prefix_26327.id
    )
    expect(records.second).to have_attributes(
      routing_plan_id: routing_plan.id,
      prefix: '34205',
      vendor_id: vendor_2.id,
      priority: 100,
      weight: 100,
      network_prefix_id: network_prefix_34205.id
    )
    expect(records.third).to have_attributes(
      routing_plan_id: routing_plan.id,
      prefix: '26327',
      vendor_id: vendor_1.id,
      priority: 95,
      weight: 100,
      network_prefix_id: network_prefix_26327.id
    )
    expect(records.fourth).to have_attributes(
      routing_plan_id: routing_plan.id,
      prefix: '34205',
      vendor_id: vendor_1.id,
      priority: 95,
      weight: 100,
      network_prefix_id: network_prefix_34205.id
    )
  end
end
