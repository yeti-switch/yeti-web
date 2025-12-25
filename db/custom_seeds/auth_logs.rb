# frozen_string_literal: true

Cdr::AuthLog.add_partitions

pop = Pop.find_or_create_by!(id: 100, name: 'seed-UA11')

200.times do
  Cdr::AuthLog.create!(
    request_time: Time.now.utc - 1.day,
    code: [nil, rand(0..700).to_i].sample,
    diversion: [nil, 'uri'].sample,
    from_uri: [nil, 'uri'].sample,
    internal_reason: [nil, 'reason'].sample,
    nonce: [nil, 'nonce'].sample,
    origination_ip: [nil, '1.2.3.4'].sample,
    origination_port: [nil, 4056].sample,
    pai: [nil, 'uri'].sample,
    ppi: [nil, 'uri'].sample,
    privacy: [nil, 'uri'].sample,
    realm: [nil, 'uri'].sample,
    reason: [nil, 'uri'].sample,
    request_method: [nil, 'uri'].sample,
    response: [nil, 'uri'].sample,
    rpid: [nil, 'uri'].sample,
    rpid_privacy: [nil, 'uri'].sample,
    ruri: [nil, 'uri'].sample,
    success: [nil, true, false].sample,
    to_uri: [nil, 'uri'].sample,
    transport_local_ip: [nil, '1.2.3.4'].sample,
    transport_local_port: [nil, rand(0..65_535).to_i].sample,
    transport_remote_ip: [nil, '1.2.3.4'].sample,
    transport_remote_port: [nil, rand(0..65_535).to_i].sample,
    username: [nil, 'uri'].sample,
    x_yeti_auth: [nil, 'uri'].sample,
    auth_error_id: [nil, rand(1..20)].sample,
    call_id: [nil, 'uri'].sample,
    gateway_id: [nil, 11].sample,
    node_id: [nil, 12].sample,
    origination_proto_id: [nil, 2].sample,
    pop_id: [nil, pop.id, rand(1..200)].sample,
    transport_proto_id: [nil, 2].sample
  )
end
