# frozen_string_literal: true

Cdr::Cdr.add_partitions

vendor = Contractor.find_or_create_by!(name: 'seed_vendor', enabled: true, vendor: true, customer: false)
vendor_acc = Account.find_or_create_by!(name: 'seed_vendor_acc', contractor: vendor)

routing_plan = Routing::RoutingPlan.find_or_create_by!(name: 'seed_routing_plan')
rate_plan = Routing::Rateplan.find_or_create_by!(name: 'seed_routing_plan')
customer = Contractor.find_or_create_by!(name: 'seed_customer', enabled: true, vendor: false, customer: true)
customer_acc = Account.find_or_create_by!(name: 'seed_customer_acc', contractor: customer)
customer_gw = Gateway.find_or_create_by!(name: 'seed_customer_gw2', contractor: customer, allow_origination: true, allow_termination: false, enabled: true, incoming_auth_password: 'pw', incoming_auth_username: 'us')
customer_auth = CustomersAuth.find_or_create_by!(name: 'seed_customer_acc', customer: customer, account: customer_acc, gateway: customer_gw, routing_plan: routing_plan, rateplan: rate_plan, require_incoming_auth: true)
pop = Pop.find_or_create_by!(id: 100_500, name: 'seed-UA')
package_counter = Billing::PackageCounter.find_or_create_by!(account_id: customer_acc.id, exclude: false, duration: 1200, prefix: 'test')

100.times do
  Routing::Area.find_or_create_by!(name: "Area #{rand(200)}")
end

200.times do
  dur = rand(-5000..5000)
  initial_time = Time.now.utc - 3.days
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

  vp = rand(0..0.99)
  cp = vp + rand(0.01..0.99)
  prof = cp - vp
  Cdr::Cdr.create!(
    time_start: initial_time,
    time_connect: connect_time,
    time_end: end_time,
    dump_level_id: Cdr::Cdr::DUMP_LEVELS.to_a.sample(1)[0][0],
    audio_recorded: true,
    disconnect_initiator_id: Cdr::Cdr::DISCONNECT_INITIATORS.to_a.sample(1)[0][0],
    internal_disconnect_code_id: [nil, rand(0..3200).to_i].sample,
    lega_disconnect_code: rand(0..630).to_i,
    internal_disconnect_code: rand(0..630).to_i,
    internal_disconnect_reason: DisconnectCode.offset(rand(DisconnectCode.count)).first.reason,
    legb_disconnect_code: rand(0..630).to_i,
    lega_q850_cause: rand(0..127).to_i,
    legb_q850_cause: rand(0..127).to_i,
    local_tag: rand(0..127).to_s,
    legb_local_tag: rand(0..127).to_s,
    routing_attempt: 1,
    is_last_cdr: true,
    success: success,
    package_counter_id: package_counter.id,
    destination_prefix: 380,
    destination_initial_rate: rand(0..5),
    destination_next_rate: rand(0..5),
    destination_reverse_billing: rand(-1..1).to_i > 0,
    dialpeer_prefix: 380,
    dialpeer_initial_rate: rand(0..5),
    dialpeer_next_rate: rand(0..5),
    dialpeer_reverse_billing: rand(-1..1).to_i > 0,
    customer: customer,
    customer_acc: customer_acc,
    vendor: vendor,
    vendor_acc: vendor_acc,
    duration: dur,
    customer_duration: [nil, dur].sample,
    customer_price: cp,
    vendor_duration: [nil, dur].sample,
    vendor_price: vp,
    profit: prof,
    dst_country: System::Country.offset(rand(System::Country.count)).first,
    dst_network: System::Network.offset(rand(System::Network.count)).first,
    src_country: System::Country.offset(rand(System::Country.count)).first,
    src_network: System::Network.offset(rand(System::Network.count)).first,
    orig_gw: customer_gw,
    customer_auth: customer_auth,
    auth_orig_ip: '1.1.1.1',
    auth_orig_port: 5060,
    sign_orig_ip: '1.2.3.4',
    sign_orig_port: 5061,
    sign_orig_local_ip: '127.0.0.1',
    sign_orig_local_port: 5061,
    sign_term_ip: '1.2.3.4',
    sign_term_port: 5061,
    sign_term_local_ip: '4.3.2.1',
    sign_term_local_port: 5061,
    pop_id: pop.id,
    src_prefix_in: '11111111111',
    src_name_in: 'Source name',
    from_domain: 'from.example.com',
    dst_prefix_in: '22222222222',
    to_domain: 'to.example.com',
    ruri_domain: 'ruri.example.com',
    src_prefix_routing: '11111111111',
    dst_prefix_routing: '22222222222',
    src_area: Routing::Area.offset(rand(Routing::Area.count)).first,
    dst_area: Routing::Area.offset(rand(Routing::Area.count)).first,
    src_name_out: 'Source name out',
    src_prefix_out: '11111111111',
    dst_prefix_out: '22222222222',
    routing_delay: 0.1223456,
    pdd: 0.1245678,
    rtt: 0.987654321,
    lega_identity: [{ "header": { "alg": 'ES256', "ppt": 'shaken', "typ": 'passport', "x5u": 'http://127.0.0.1/share/test.pem' }, "parsed": true, "payload": { "attest": 'C', "dest": { "tn": '456', "uri": 'sip:456' }, "iat": 1_622_830_203, "orig": { "tn": '123', "uri": 'sip:123' }, "origid": '8-000F7304-60BA6C7B000B6828-A43657C0' }, "verified": true }, { "error_code": 4, "error_reason": 'Incorrect Identity Header Value', "parsed": false }, { "error_code": -1, "error_reason": 'certificate is not available', "header": { "alg": 'ES256', "ppt": 'shaken', "typ": 'passport', "x5u": 'http://127.0.0.1/share/test2.pem' }, "parsed": true, "payload": { "attest": 'C', "dest": { "tn": '13' }, "iat": 1_622_831_252, "orig": { "tn": '42' }, "origid": '8-000F7304-60BA7094000207EC-2B5F27C0' }, "verified": false }],
    lega_ss_status_id: [nil, -1, 0, 1, 2, 3].sample,
    legb_ss_status_id: [nil, -1, 0, 1, 2, 3].sample,
    metadata: [nil, { key: 'value', hash: { key1: 'value1', key2: 1000 } }].sample
  )
end
