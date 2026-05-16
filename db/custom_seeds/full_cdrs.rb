# frozen_string_literal: true

Cdr::Cdr.add_partitions
RtpStatistics::RxStream.add_partition_for(Time.now.utc - 1.day)
RtpStatistics::RxStream.add_partition_for(Time.now.utc)
RtpStatistics::TxStream.add_partition_for(Time.now.utc - 1.day)
RtpStatistics::TxStream.add_partition_for(Time.now.utc)

vendor = Contractor.find_or_create_by!(name: 'seed_vendor', enabled: true, vendor: true, customer: false)
vendor_acc = Account.find_or_create_by!(name: 'seed_vendor_acc', contractor: vendor)

routing_plan = Routing::RoutingPlan.find_or_create_by!(name: 'seed_routing_plan')
rate_plan = Routing::Rateplan.find_or_create_by!(name: 'seed_routing_plan')
customer = Contractor.find_or_create_by!(name: 'seed_customer22', enabled: true, vendor: false, customer: true)
customer_acc = Account.find_or_create_by!(name: 'seed_customer_acc22', contractor: customer)

# Currencies for CDR display testing: system currency (id=0) always exists with rate=1
# Create a couple of non-base currencies with sample rates
seed_currencies = [
  { name: 'USD', rate: 1.08 },
  { name: 'UAH', rate: 0.024 }
]
seed_currencies.each do |attrs|
  Billing::Currency.find_or_create_by!(name: attrs[:name]) do |c|
    c.rate = attrs[:rate]
  end
end

# Pool of currencies to assign to CDRs: system currency (id=0) + USD + UAH
cdr_currencies = Billing::Currency.where(id: 0).or(Billing::Currency.where(name: %w[USD UAH])).to_a
customer_gw = Gateway.find_or_create_by!(name: 'seed_customer_gw22') do |r|
  r.contractor = customer
  r.allow_origination = true
  r.allow_termination = false
  r.enabled = true
  r.incoming_auth_password = 'pw'
  r.incoming_auth_username = 'us'
end
customer_auth = CustomersAuth.find_or_create_by!(name: 'seed_customer_auth22') do |r|
  r.customer = customer
  r.account = customer_acc
  r.gateway = customer_gw
  r.routing_plan = routing_plan
  r.rateplan = rate_plan
  r.require_incoming_auth = true
end
pop = Pop.find_or_create_by!(id: 100_500, name: 'seed-UA')
seed_node = Node.find_or_create_by!(id: 100_500) do |n|
  n.name = 'seed-node'
  n.rpc_endpoint = 'tcp://127.0.0.1:7080'
  n.pop = pop
end

seed_term_gws = (1..3).map do |i|
  Gateway.find_or_create_by!(name: "seed_term_gw#{i}") do |gw|
    gw.contractor = vendor
    gw.allow_origination = false
    gw.allow_termination = true
    gw.enabled = true
    gw.host = "203.0.113.#{i}"
  end
end
package_counter = Billing::PackageCounter.find_or_create_by!(account_id: customer_acc.id, exclude: false, duration: 1200, prefix: 'test')

100.times do
  Routing::Area.find_or_create_by!(name: "Area #{rand(200)}")
end

sample_diversion_uris = [
  nil,
  'sip:+12025551234@gw1.example.com',
  '"Receptionist" <sip:1000@office.example.com>;reason=unconditional',
  'sip:380441234567@ukr.example.net;reason=no-answer',
  '<sip:+442071234567@london.example.com:5060>;reason=user-busy',
  'tel:+33123456789',
  '<sip:+12025551234@gw1.example.com>;reason=unconditional, <sip:+12025559999@gw2.example.com>;reason=no-answer',
  'sip:1000@office.example.com, sip:2000@office.example.com, sip:3000@office.example.com'
].freeze

sample_pai_uris = [
  nil,
  'sip:+12025559876@carrier.example.com',
  '"John Smith" <sip:jsmith@enterprise.example.com>',
  '<sip:+380501234567@ukr.example.net:5060;transport=tcp>',
  'sip:anonymous@anonymous.invalid',
  'tel:+4915112345678',
  '"Alice" <sip:alice@atlanta.example.com>, "Bob" <sip:bob@biloxi.example.com>',
  'sip:+12025551111@carrier1.example.com, sip:+12025552222@carrier2.example.com'
].freeze

sample_ppi_uris = [
  nil,
  'sip:+12025554321@proxy.example.com',
  '"Alice" <sip:alice@atlanta.example.com>',
  'sip:+380671234567@mobile.example.net',
  'tel:+81312345678'
].freeze

sample_rpid_uris = [
  nil,
  'sip:+12025551111@rpid.example.com',
  '"Bob" <sip:bob@biloxi.example.com>;party=calling;screen=yes',
  '<sip:+380441111111@kyiv.example.net>;privacy=off;screen=no',
  'tel:+61212345678'
].freeze

sample_privacy_values = [nil, 'none', 'id', 'header', 'session', 'id;header', 'critical'].freeze
sample_rpid_privacy_values = [nil, 'full', 'name', 'uri', 'off'].freeze

create_rtp_streams = lambda do |tag, gateway, time_start, time_end, rx_packets: nil, tx_packets: nil|
  common = {
    local_tag: tag,
    gateway: gateway,
    pop: pop,
    node: seed_node,
    time_start: time_start,
    time_end: time_end,
    local_host: '10.0.0.1',
    local_port: rand(10_000..30_000)
  }
  rx_pkts = rx_packets || rand(500..5000)
  tx_pkts = tx_packets || rand(500..5000)

  # Create the TX stream first so RX stream(s) can link to it via
  # tx_stream_id, matching production (switch.write_rtp_statistics).
  tx = RtpStatistics::TxStream.create!(common.merge(
                                         tx_ssrc: rand(1..2**31),
                                         tx_packets: tx_pkts,
                                         tx_bytes: tx_pkts * 160,
                                         tx_total_lost: rand(0..tx_pkts / 20),
                                         tx_payloads_relayed: %w[PCMU],
                                         tx_payloads_transcoded: [],
                                         rtcp_rtt_mean: rand(0.01..0.3).round(6),
                                         # receive-side error counters (mostly clean, occasional errors)
                                         rx_out_of_buffer_errors: rand < 0.15 ? rand(1..20) : 0,
                                         rx_rtp_parse_errors: rand < 0.1 ? rand(1..10) : 0,
                                         rx_dropped_packets: rand < 0.2 ? rand(1..rx_pkts / 50) : 0,
                                         rx_srtp_decrypt_errors: rand < 0.05 ? rand(1..5) : 0
                                       ))

  # 50% of legs get several RX streams tied to the same TX stream
  # (re-INVITE / multi-SSRC). Remote sockets are a mix of shared and
  # distinct values so the diagram's dedup rendering is exercised.
  rx_count = rand < 0.5 ? rand(2..3) : 1
  base_remote_port = rand(10_000..30_000)

  rx_count.times do |i|
    remote_port = i.zero? || rand < 0.5 ? base_remote_port : rand(10_000..30_000)
    RtpStatistics::RxStream.create!(common.merge(
                                      tx_stream_id: tx.id,
                                      remote_host: '10.0.0.2',
                                      remote_port: remote_port,
                                      rx_ssrc: rand(1..2**31),
                                      rx_packets: rx_pkts,
                                      rx_bytes: rx_pkts * 160,
                                      rx_total_lost: rand(0..rx_pkts / 20),
                                      rx_payloads_relayed: %w[PCMU],
                                      rx_payloads_transcoded: [],
                                      rx_decode_errors: 0,
                                      rx_packet_jitter_mean: rand(0.0001..0.05).round(6),
                                      rx_packet_jitter_max: rand(0.001..0.1).round(6)
                                    ))
  end
end

200.times do |call_idx|
  initial_time = Time.now.utc - 1.day - call_idx.seconds
  call_local_tag = "seed-lega-#{SecureRandom.hex(6)}"

  # ~30% of calls have 2-3 attempts (reroute scenario); rest are single-attempt
  num_attempts = rand < 0.3 ? rand(2..3) : 1
  attempt_term_gws = Array.new(num_attempts) { seed_term_gws.sample }

  # LegA streams are tied to the call (one orig_gw, one local_tag) — create once per call
  call_end_estimate = initial_time + 300.seconds
  create_rtp_streams.call(call_local_tag, customer_gw, initial_time, call_end_estimate)

  attempt_term_gws.each_with_index do |term_gw, attempt_idx|
    is_last_attempt = (attempt_idx == num_attempts - 1)
    legb_local_tag = "seed-legb-#{SecureRandom.hex(6)}"

    dur = is_last_attempt ? rand(-5000..5000) : -1
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

    customer_currency = cdr_currencies.sample
    vendor_currency = cdr_currencies.sample

    vp = rand(0..0.99).round(6)
    cp = (vp + rand(0.01..0.99)).round(6)
    prof = (cp * customer_currency.rate - vp * vendor_currency.rate).round(6)

    cdr = Cdr::Cdr.create!(
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
      local_tag: call_local_tag,
      legb_local_tag: legb_local_tag,
      routing_attempt: attempt_idx + 1,
      is_last_cdr: is_last_attempt,
      success: success,
      package_counter_id: package_counter.id,
      destination_prefix: 380,
      destination_initial_rate: rand(0..5),
      destination_next_rate: rand(0..5),
      destination_reverse_billing: [nil, true, false].sample,
      destination_rate_policy_id: [nil, 1, 2, 3, 4].sample,
      dialpeer_prefix: 380,
      dialpeer_initial_rate: rand(0..5),
      dialpeer_next_rate: rand(0..5),
      dialpeer_reverse_billing: [nil, true, false].sample,
      customer: customer,
      customer_acc: customer_acc,
      vendor: vendor,
      vendor_acc: vendor_acc,
      duration: dur,
      customer_duration: [nil, dur].sample,
      customer_price: cp,
      customer_currency_id: customer_currency.id,
      customer_currency_rate: customer_currency.rate,
      vendor_duration: [nil, dur].sample,
      vendor_price: vp,
      vendor_currency_id: vendor_currency.id,
      vendor_currency_rate: vendor_currency.rate,
      profit: prof,
      dst_country: System::Country.offset(rand(System::Country.count)).first,
      dst_network: System::Network.offset(rand(System::Network.count)).first,
      src_country: System::Country.offset(rand(System::Country.count)).first,
      src_network: System::Network.offset(rand(System::Network.count)).first,
      orig_gw: customer_gw,
      term_gw: term_gw,
      customer_auth: customer_auth,
      node_id: seed_node.id,
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
      diversion_in: sample_diversion_uris.sample,
      pai_in: sample_pai_uris.sample,
      ppi_in: sample_ppi_uris.sample,
      privacy_in: sample_privacy_values.sample,
      rpid_in: sample_rpid_uris.sample,
      rpid_privacy_in: sample_rpid_privacy_values.sample,
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

    # LegB streams for this attempt (Yeti <-> term_gw, unique legb_local_tag)
    legb_end = end_time || (initial_time + 300.seconds)
    create_rtp_streams.call(legb_local_tag, term_gw, initial_time, legb_end)
  end
end
