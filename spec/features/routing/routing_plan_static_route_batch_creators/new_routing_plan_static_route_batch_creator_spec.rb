# frozen_string_literal: true

RSpec.xdescribe 'Create new Routing Plan Static Route Batch Creator', type: :feature, js: true do
  subject do
    aa_form.submit
  end

  active_admin_form_for Routing::RoutingPlanStaticRouteBatchCreatorForm, 'new'
  include_context :login_as_admin

  let!(:vendor_1) { FactoryBot.create(:vendor) }
  let!(:vendor_2) { FactoryBot.create(:vendor) }
  let!(:routing_plan) { FactoryBot.create(:routing_plan, :with_static_routes) }
  before do
    FactoryBot.create(:routing_plan)
    FactoryBot.create(:routing_plan, :with_static_routes)
    FactoryBot.create(:vendor)

    visit new_routing_plan_static_route_batch_creator_path

    aa_form.search_chosen 'Routing plan', routing_plan.display_name, ajax: true
    aa_form.set_text 'Prefixes', '123,456'
    aa_form.search_chosen 'Vendors', vendor_2.display_name, ajax: true, multiple: true
    aa_form.search_chosen 'Vendors', vendor_1.display_name, ajax: true, multiple: true
  end

  it 'creates record' do
    subject
    records = Routing::RoutingPlanStaticRoute.last(4)
    expect(records.size).to eq(4)
    network_prefix_123 = System::NetworkPrefix.longest_match('123')
    network_prefix_456 = System::NetworkPrefix.longest_match('456')
    expect(records.first).to have_attributes(
      routing_plan_id: routing_plan.id,
      prefix: '123',
      vendor_id: vendor_2.id,
      priority: 100,
      weight: 100,
      network_prefix_id: network_prefix_123.id
    )
    expect(records.second).to have_attributes(
      routing_plan_id: routing_plan.id,
      prefix: '456',
      vendor_id: vendor_2.id,
      priority: 100,
      weight: 100,
      network_prefix_id: network_prefix_456.id
    )
    expect(records.third).to have_attributes(
      routing_plan_id: routing_plan.id,
      prefix: '123',
      vendor_id: vendor_1.id,
      priority: 95,
      weight: 100,
      network_prefix_id: network_prefix_123.id
    )
    expect(records.fourth).to have_attributes(
      routing_plan_id: routing_plan.id,
      prefix: '456',
      vendor_id: vendor_1.id,
      priority: 95,
      weight: 100,
      network_prefix_id: network_prefix_456.id
    )
  end

  include_examples :changes_records_qty_of, Routing::RoutingPlanStaticRoute, by: 4 # 2 vendors X 2 prefixes
  include_examples :shows_flash_message, :notice, 'Routing plan static route batch creator was successfully created.'
end
