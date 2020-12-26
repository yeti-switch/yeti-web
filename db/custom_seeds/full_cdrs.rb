# frozen_string_literal: true
Cdr::Cdr.add_partitions

vendor=Contractor.find_or_create_by!(name: 'seed_vendor', enabled: true, vendor: true, customer: false)
vendor_acc=Account.find_or_create_by!(name: 'seed_vendor_acc', contractor: vendor)

routing_plan = Routing::RoutingPlan.find_or_create_by!(name: 'seed_routing_plan')
rate_plan = Routing::Rateplan.find_or_create_by!(name: 'seed_routing_plan')
customer=Contractor.find_or_create_by!(name: 'seed_customer', enabled: true, vendor: false, customer: true)
customer_acc=Account.find_or_create_by!(name: 'seed_customer_acc', contractor: customer)
customer_gw = Gateway.find_or_create_by!(name: 'seed_customer_gw', contractor: customer, allow_origination: true, allow_termination: false, enabled: true, incoming_auth_password: 'pw', incoming_auth_username: 'us')
customer_auth = CustomersAuth.find_or_create_by!(name: 'seed_customer_acc', customer: customer, account: customer_acc, gateway: customer_gw, routing_plan: routing_plan, rateplan: rate_plan, require_incoming_auth: true )
pop = Pop.find_or_create_by!(id: 100500, name: 'seed-UA')

200.times do
  dur = rand(7200) - 1000;
  initial_time = Time.now.utc - 3600*24*30
  if dur > 0
    connect_time = initial_time + rand(40)
    end_time = connect_time + dur
    success = true
  else
    dur = 0
    connect_time = nil
    end_time = initial_time + rand(120)
    success = false
  end
  Cdr::Cdr.create!(
    time_start: initial_time,
    time_connect: connect_time,
    time_end: end_time,
    disconnect_initiator: DisconnectInitiator.offset(rand(DisconnectInitiator.count)).first,
    routing_attempt: 1,
    is_last_cdr: true,
    success: success,
    destination_prefix: 380,
    dialpeer_prefix: 380,
    customer: customer,
    customer_acc: customer_acc,
    vendor: vendor,
    vendor_acc: vendor_acc,
    duration: dur,
    customer_duration: dur,
    customer_price: rand(),
    vendor_duration: dur,
    vendor_price: rand(),
    dst_country: System::Country.offset(rand(System::Country.count)).first,
    dst_network: System::Network.offset(rand(System::Network.count)).first,
    orig_gw: customer_gw,
    customer_auth: customer_auth,
    auth_orig_ip: '1.1.1.1',
    auth_orig_port: 5060,
    pop_id: pop.id,
    src_prefix_in: '11111111111',
    dst_prefix_in: '22222222222'
  )
end