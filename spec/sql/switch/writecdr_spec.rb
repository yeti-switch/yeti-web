# frozen_string_literal: true

RSpec.describe 'switch.writecdr()' do
  subject do
    SqlCaller::Cdr.execute("SELECT switch.writecdr(#{writecdr_parameters});")
  end

  before do
    # disable rounding
    System::CdrConfig.take!.update!(
      customer_amount_round_mode_id: 1,
      vendor_amount_round_mode_id: 1
    )
  end

  let(:time_start) { 10.minutes.ago }
  let(:leg_b_time) { time_start + 10.seconds }
  let(:time_connect) { time_start + 40.seconds }
  let(:time_end) { Time.now }
  let(:time_1xx) { time_start + 20.seconds }
  let(:time_18x) { time_start + 30.seconds }

  let(:i_time_data) do
    {
      "time_start": time_start.to_f,
      "leg_b_time": leg_b_time.to_f,
      "time_connect": time_connect.to_f,
      "time_end": time_end.to_f,
      "time_1xx": time_1xx.to_f,
      "time_18x": time_18x.to_f,
      "time_limit": 7200,
      "isup_propagation_delay": 0
    }.to_json
  end

  let(:i_rtp_statistics) do
    [
      {
        "local_tag": '8-053E9F9A-61A0C677000C790C-DCBDE700',
        "rtcp_rtt_min": 0,
        "rtcp_rtt_max": 0,
        "rtcp_rtt_mean": 0,
        "rtcp_rtt_std": 0,
        "time_start": 10.seconds.ago.to_f,
        "time_end": Time.now.to_f,
        "rx_out_of_buffer_errors": 0,
        "rx_rtp_parse_errors": 0,
        "rx_dropped_packets": 0,
        "rx": [
          {
            "rx_ssrc": 267_906_310,
            "remote_host": '192.168.240.109',
            "remote_port": 40_000,
            "rx_packets": 1029,
            "rx_bytes": 164_640,
            "rx_total_lost": 0,
            "rx_payloads_transcoded": 'g711,g723',
            "rx_payloads_relayed": 'pcmu,pcma',
            "rx_decode_errors": 0,
            "rx_packet_delta_min": 19,
            "rx_packet_delta_max": 20,
            "rx_packet_delta_mean": 20.000097,
            "rx_packet_delta_std": 0.018844,
            "rx_packet_jitter_min": 0,
            "rx_packet_jitter_max": 0.033933,
            "rx_packet_jitter_mean": 0.022334,
            "rx_packet_jitter_std": 0.003014,
            "rx_rtcp_jitter_min": 0,
            "rx_rtcp_jitter_max": 0,
            "rx_rtcp_jitter_mean": 0,
            "rx_rtcp_jitter_std": 0
          }
        ],
        "tx_packets": 5,
        "tx_bytes": 300,
        "tx_ssrc": 1_316_747_124,
        "local_host": '192.168.240.109',
        "local_port": 10_048,
        "tx_total_lost": 0,
        "tx_payloads_transcoded": 'pcma,pcmu',
        "tx_payloads_relayed": 'g711,g726',
        "tx_rtcp_jitter_min": 0,
        "tx_rtcp_jitter_max": 0,
        "tx_rtcp_jitter_mean": 0,
        "tx_rtcp_jitter_std": 0
      },
      {
        "local_tag": '8-053E9F9A-61A0C677000C790C-DCBDE700',
        "rtcp_rtt_min": 0,
        "rtcp_rtt_max": 0,
        "rtcp_rtt_mean": 0,
        "rtcp_rtt_std": 0,
        "time_start": 10.seconds.ago.to_f,
        "time_end": Time.now.to_f,
        "rx_out_of_buffer_errors": 0,
        "rx_rtp_parse_errors": 0,
        "rx_dropped_packets": 0,
        "rx": [
          {
            "rx_ssrc": 267_906_310,
            "remote_host": '192.168.240.109',
            "remote_port": 40_000,
            "rx_packets": 1029,
            "rx_bytes": 164_640,
            "rx_total_lost": 0,
            "rx_payloads_transcoded": '',
            "rx_payloads_relayed": 'pcmu',
            "rx_decode_errors": 0,
            "rx_packet_delta_min": 19,
            "rx_packet_delta_max": 20,
            "rx_packet_delta_mean": 20.000097,
            "rx_packet_delta_std": 0.018844,
            "rx_packet_jitter_min": 0,
            "rx_packet_jitter_max": 0.033933,
            "rx_packet_jitter_mean": 0.022334,
            "rx_packet_jitter_std": 0.003014,
            "rx_rtcp_jitter_min": 0,
            "rx_rtcp_jitter_max": 0,
            "rx_rtcp_jitter_mean": 0,
            "rx_rtcp_jitter_std": 0
          }

        ],
        "tx_packets": 0,
        "tx_bytes": 0,
        "tx_ssrc": 287_288_557,
        "local_host": '::',
        "local_port": 0,
        "tx_total_lost": 0,
        "tx_payloads_transcoded": '',
        "tx_payloads_relayed": '',
        "tx_rtcp_jitter_min": 0,
        "tx_rtcp_jitter_max": 0,
        "tx_rtcp_jitter_mean": 0,
        "tx_rtcp_jitter_std": 0
      },
      {
        "local_tag": '8-3C5106AE-61A0C677000DA59F-25C20700',
        "rtcp_rtt_min": 0,
        "rtcp_rtt_max": 0,
        "rtcp_rtt_mean": 0,
        "rtcp_rtt_std": 0,
        "time_start": 10.seconds.ago.to_f,
        "time_end": Time.now.to_f,
        "rx_out_of_buffer_errors": 0,
        "rx_rtp_parse_errors": 0,
        "rx_dropped_packets": 0,
        "rx": [
          {
            "rx_ssrc": 1_458_718_330,
            "remote_host": '192.168.240.109',
            "remote_port": 40_064,
            "rx_packets": 3,
            "rx_bytes": 480,
            "rx_total_lost": 0,
            "rx_payloads_transcoded": '',
            "rx_payloads_relayed": '',
            "rx_decode_errors": 0,
            "rx_packet_delta_min": 20,
            "rx_packet_delta_max": 20,
            "rx_packet_delta_mean": 20.003000,
            "rx_packet_delta_std": 0,
            "rx_packet_jitter_min": 0,
            "rx_packet_jitter_max": 0,
            "rx_packet_jitter_mean": 0,
            "rx_packet_jitter_std": 0,
            "rx_rtcp_jitter_min": 0,
            "rx_rtcp_jitter_max": 0,
            "rx_rtcp_jitter_mean": 0,
            "rx_rtcp_jitter_std": 0
          }
        ],
        "tx_packets": 1031,
        "tx_bytes": 164_480,
        "tx_ssrc": 1_541_126_890,
        "local_host": '192.168.240.109',
        "local_port": 10_000,
        "tx_total_lost": 0,
        "tx_payloads_transcoded": '',
        "tx_payloads_relayed": 'pcmu',
        "tx_rtcp_jitter_min": 0,
        "tx_rtcp_jitter_max": 0,
        "tx_rtcp_jitter_mean": 0,
        "tx_rtcp_jitter_std": 0
      },
      {
        "local_tag": '8-3C5106AE-61A0C677000DA59F-25C20700',
        "rtcp_rtt_min": 0,
        "rtcp_rtt_max": 0,
        "rtcp_rtt_mean": 0,
        "rtcp_rtt_std": 0,
        "time_start": 10.seconds.ago.to_f,
        "time_end": Time.now.to_f,
        "rx_out_of_buffer_errors": 0,
        "rx_rtp_parse_errors": 0,
        "rx_dropped_packets": 0,
        "rx": [
          {
            "rx_ssrc": 1_458_718_330,
            "remote_host": '192.168.240.109',
            "remote_port": 40_064,
            "rx_packets": 3,
            "rx_bytes": 480,
            "rx_total_lost": 0,
            "rx_payloads_transcoded": '',
            "rx_payloads_relayed": '',
            "rx_decode_errors": 0,
            "rx_packet_delta_min": 20,
            "rx_packet_delta_max": 20,
            "rx_packet_delta_mean": 20.003000,
            "rx_packet_delta_std": 0,
            "rx_packet_jitter_min": 0,
            "rx_packet_jitter_max": 0,
            "rx_packet_jitter_mean": 0,
            "rx_packet_jitter_std": 0,
            "rx_rtcp_jitter_min": 0,
            "rx_rtcp_jitter_max": 0,
            "rx_rtcp_jitter_mean": 0,
            "rx_rtcp_jitter_std": 0
          }

        ],
        "tx_packets": 0,
        "tx_bytes": 0,
        "tx_ssrc": 1_636_739_746,
        "local_host": '::',
        "local_port": 0,
        "tx_total_lost": 0,
        "tx_payloads_transcoded": '',
        "tx_payloads_relayed": '',
        "tx_rtcp_jitter_min": 0,
        "tx_rtcp_jitter_max": 0,
        "tx_rtcp_jitter_mean": 0,
        "tx_rtcp_jitter_std": 0
      }
    ].to_json
  end

  let(:i_dynamic_fields) do
    {
      "customer_auth_name": 'Customer Auth for trunk 1',
      "customer_id": 1105,
      "vendor_id": 1755,
      "customer_acc_id": 1886,
      "vendor_acc_id": 32,
      "customer_auth_id": 20_084,
      "destination_id": 4_201_534,
      "destination_prefix": '',
      "dialpeer_id": 1_376_789,
      "dialpeer_prefix": '',
      "orig_gw_id": 17,
      "term_gw_id": 39,
      "routing_group_id": 22,
      "rateplan_id": 14,
      "destination_initial_rate": '0.0001',
      "destination_next_rate": '0.0001',
      "destination_initial_interval": 60,
      "destination_next_interval": 11,
      "destination_rate_policy_id": 1442,
      "dialpeer_initial_interval": 12,
      "dialpeer_next_interval": 13,
      "dialpeer_next_rate": '1.0',
      "destination_fee": '0.0',
      "dialpeer_initial_rate": '1.0',
      "dialpeer_fee": '0.0',
      "dst_prefix_in": '380947100008',
      "dst_prefix_out": 'echotest',
      "src_prefix_in": 'h',
      "src_prefix_out": '380947111223',
      "src_name_in": '',
      "src_name_out": '',
      "diversion_in": 'rspec-diversion-in', "diversion_out": 'rspec-diversion-out',
      "auth_orig_protocol_id": 1567, "auth_orig_ip": '127.0.0.1', "auth_orig_port": 1947,
      "src_country_id": 111, "src_network_id": 333, "dst_country_id": 222, "dst_network_id": 1533,
      "dst_prefix_routing": '380947100008',
      "src_prefix_routing": '380947111223',
      "routing_plan_id": 1,
      "lrn": 'rspec-lrn',
      "lnp_database_id": 111,
      "from_domain": 'node-10.yeti-sandbox.localhost', "to_domain": 'node-10.yeti-sandbox.localhost', "ruri_domain": 'node-10.yeti-sandbox.localhost',
      "src_area_id": 222, "dst_area_id": 333, "routing_tag_ids": '{9}',
      "pai_in": 'rspec-pai-in', "ppi_in": 'rspec-ppi-in',
      "privacy_in": 'rspec-privacy-in', "rpid_in": 'rspec-rpid-in', "rpid_privacy_in": 'rspec-rpid-privacy-in',
      "pai_out": 'rspec-pai-out', "ppi_out": 'rspec-ppi-out',
      "privacy_out": 'rspec-privacy-out', "rpid_out": 'rspec-rpid-out', "rpid_privacy_out": 'rspec-rpid-privacy-out',
      "customer_acc_check_balance": true, "destination_reverse_billing": false, "dialpeer_reverse_billing": false,
      "customer_auth_external_id": 1504, "customer_external_id": 156_998, "vendor_external_id": 1111,
      "customer_acc_external_id": 156_998, "vendor_acc_external_id": 2222, "orig_gw_external_id": 1,
      "term_gw_external_id": 4444, "customer_acc_vat": '23.0',
      "metadata": metadata,
      "customer_auth_external_type": 'term',
      "lega_ss_status_id": -1,
      "legb_ss_status_id": 2
    }.to_json
  end

  let!(:metadata) { nil }

  let(:writecdr_parameters) do
    %(
        't',
        '10',
        '3',
        '4',
        't',
        '#{lega_transport_protocol_id}',
        '#{lega_local_ip}',
        '#{lega_local_port}',
        '#{lega_remote_ip}',
        '#{lega_remote_port}',
        '#{legb_transport_protocol_id}',
        '#{legb_local_ip}',
        '#{legb_local_port}',
        '#{legb_remote_ip}',
        '#{legb_remote_port}',
        'sip:ruri@example.com:8090;transport=TCP',
        'sip:outbound-proxy@example.com:8090;transport=TCP',
        '#{i_time_data}',
        'f',
        '200',
        'Bye',
        '3',
        '200',
        'Bye',
        '200',
        'Bye',
        'dhgxlgaifhhmovy@elo',
        '08889A81-5ABE27EE000480C0-EE666700',
        '73F4856A-5ABE27EE00047ECE-CD83B700',
        '99F4856A-5ABE27EE00047ECE-CD83B711',
        '/var/spool/sems/dump/73F4856A-5ABE27EE00047ECE-CD83B700_10.pcap',
        '0',
        'f',
        '{}',
        '#{i_rtp_statistics}',
        '',
        '',
        '[]',
        3::smallint,
        1551231112::bigint,
        NULL,
        '{"core":"1.7.60-4","yeti":"1.7.30-1","aleg":"Twinkle/1.10.1","bleg":"Localhost Media Gateway"}',
        'f',
        '#{i_dynamic_fields}',
        '{"p_charge_info":"sip:p-charge-info@example.com/uri","reason":{ "q850_cause":16,"q850_text":"Normal call clearing", "q850_params":"sparam1; sparam2=test; sparam3=test"}}',
        '{"v_info":"sip:p-charge-info@example.com/uri","reason":{ "q850_cause":32,"q850_text":"test", "q850_params":"sparam1"}}',
        '[{"header":{"alg":"ES256","ppt":"shaken","typ":"passport","x5u":"http://127.0.0.1/share/test.pem"},"parsed":true,"payload":{"attest":"C","dest":{"tn":"456","uri":"sip:456"},"iat":1622830203,"orig":{"tn":"123","uri":"sip:123"},"origid":"8-000F7304-60BA6C7B000B6828-A43657C0"},"verified":true},{"error_code":4,"error_reason":"Incorrect Identity Header Value","parsed":false},{"error_code":-1,"error_reason":"certificate is not available","header":{"alg":"ES256","ppt":"shaken","typ":"passport","x5u":"http://127.0.0.1/share/test2.pem"},"parsed":true,"payload":{"attest":"C","dest":{"tn":"13"},"iat":1622831252,"orig":{"tn":"42"},"origid":"8-000F7304-60BA7094000207EC-2B5F27C0"},"verified":false}]'
      )
  end

  let(:lega_transport_protocol_id) { 1 }
  let(:lega_local_ip) { '127.0.0.3' }
  let(:lega_local_port) { 7878 }
  let(:lega_remote_ip) { '127.0.0.5' }
  let(:lega_remote_port) { 9090 }

  let(:legb_transport_protocol_id) { 1 }
  let(:legb_local_ip) { '127.0.0.3' }
  let(:legb_local_port) { 7687 }
  let(:legb_remote_ip) { '127.0.0.99' }
  let(:legb_remote_port) { 88_888 }

  it 'creates new CDR-record' do
    expect { subject }.to change { Cdr::Cdr.count }.by(1)
  end

  it 'creates CDR with expected attributes' do
    subject
    cdr = Cdr::Cdr.last
    expect(cdr).to have_attributes(
                     id: kind_of(Integer),
                     customer_id: 1105,
                     vendor_id: 1755,
                     customer_acc_id: 1886,
                     vendor_acc_id: 32,
                     customer_auth_id: 20_084,
                     destination_id: 4_201_534,
                     dialpeer_id: 1_376_789,
                     orig_gw_id: 17,
                     term_gw_id: 39,
                     routing_group_id: 22,
                     rateplan_id: 14,
                     destination_next_rate: 0.0001,
                     destination_fee: 0.0,
                     dialpeer_next_rate: 1.0,
                     dialpeer_fee: 0.0,
                     internal_disconnect_code: 200,
                     internal_disconnect_reason: 'Bye',
                     disconnect_initiator_id: 3,
                     customer_acc_vat: 23.0,
                     customer_price: be_within(0.00002).of(0.00115),
                     customer_price_no_vat: be_within(0.00001).of(0.00094),
                     vendor_price: be_within(0.1).of(9.5),
                     duration: 560,
                     success: true,
                     profit: be_within(0.1).of(-9.5),
                     dst_prefix_in: '380947100008',
                     dst_prefix_out: 'echotest',
                     src_prefix_in: 'h',
                     src_prefix_out: '380947111223',
                     time_start: be_within(1.second).of(time_start),
                     time_connect: be_within(1.second).of(time_connect),
                     time_end: be_within(1.second).of(time_end),
                     sign_orig_ip: lega_remote_ip,
                     sign_orig_port: lega_remote_port,
                     sign_orig_local_ip: lega_local_ip,
                     sign_orig_local_port: lega_local_port,
                     sign_term_ip: legb_remote_ip,
                     sign_term_port: legb_remote_port,
                     sign_term_local_ip: legb_local_ip,
                     sign_term_local_port: legb_local_port,
                     orig_call_id: 'dhgxlgaifhhmovy@elo',
                     term_call_id: '08889A81-5ABE27EE000480C0-EE666700',
                     vendor_invoice_id: nil,
                     customer_invoice_id: nil,
                     local_tag: '73F4856A-5ABE27EE00047ECE-CD83B700',
                     legb_local_tag: '99F4856A-5ABE27EE00047ECE-CD83B711',
                     legb_ruri: 'sip:ruri@example.com:8090;transport=TCP',
                     legb_outbound_proxy: 'sip:outbound-proxy@example.com:8090;transport=TCP',
                     destination_initial_rate: 0.0001,
                     dialpeer_initial_rate: 1.0,
                     destination_initial_interval: 60,
                     destination_next_interval: 11,
                     dialpeer_initial_interval: 12,
                     dialpeer_next_interval: 13,
                     destination_rate_policy_id: 1442,
                     routing_attempt: 4,
                     is_last_cdr: true,
                     lega_disconnect_code: 200,
                     lega_disconnect_reason: 'Bye',
                     pop_id: 3,
                     node_id: 10,
                     src_name_in: '',
                     src_name_out: '',
                     diversion_in: 'rspec-diversion-in',
                     diversion_out: 'rspec-diversion-out',
                     legb_disconnect_code: 200,
                     legb_disconnect_reason: 'Bye',
                     dump_level_id: 0,
                     auth_orig_ip: '127.0.0.1',
                     auth_orig_port: 1947,
                     global_tag: '',
                     src_country_id: 111,
                     src_network_id: 333,
                     dst_country_id: 222,
                     dst_network_id: 1533,
                     src_prefix_routing: '380947111223',
                     dst_prefix_routing: '380947100008',
                     routing_plan_id: 1,
                     routing_delay: 10.0,
                     pdd: 30.0,
                     rtt: 10.0,
                     early_media_present: false,
                     lnp_database_id: 111,
                     lrn: 'rspec-lrn',
                     destination_prefix: '',
                     dialpeer_prefix: '',
                     audio_recorded: false,
                     ruri_domain: 'node-10.yeti-sandbox.localhost',
                     to_domain: 'node-10.yeti-sandbox.localhost',
                     from_domain: 'node-10.yeti-sandbox.localhost',
                     src_area_id: 222,
                     dst_area_id: 333,
                     auth_orig_transport_protocol_id: 1567,
                     sign_orig_transport_protocol_id: lega_transport_protocol_id,
                     sign_term_transport_protocol_id: legb_transport_protocol_id,
                     core_version: '1.7.60-4',
                     yeti_version: '1.7.30-1',
                     lega_user_agent: 'Twinkle/1.10.1',
                     legb_user_agent: 'Localhost Media Gateway',
                     uuid: kind_of(String),
                     pai_in: 'rspec-pai-in',
                     ppi_in: 'rspec-ppi-in',
                     privacy_in: 'rspec-privacy-in',
                     rpid_in: 'rspec-rpid-in',
                     rpid_privacy_in: 'rspec-rpid-privacy-in',
                     pai_out: 'rspec-pai-out',
                     ppi_out: 'rspec-ppi-out',
                     privacy_out: 'rspec-privacy-out',
                     rpid_out: 'rspec-rpid-out',
                     rpid_privacy_out: 'rspec-rpid-privacy-out',
                     destination_reverse_billing: false,
                     dialpeer_reverse_billing: false,
                     is_redirected: false,
                     customer_account_check_balance: true,
                     customer_external_id: 156_998,
                     customer_auth_external_id: 1504,
                     customer_auth_external_type: 'term',
                     customer_acc_external_id: 156_998,
                     routing_tag_ids: [9],
                     vendor_external_id: 1111,
                     vendor_acc_external_id: 2222,
                     orig_gw_external_id: 1,
                     term_gw_external_id: 4444,
                     failed_resource_type_id: 3,
                     failed_resource_id: 1_551_231_112,
                     customer_duration: 566,
                     vendor_duration: 571,
                     customer_auth_name: 'Customer Auth for trunk 1',
                     p_charge_info_in: 'sip:p-charge-info@example.com/uri',
                     lega_q850_cause: 16,
                     lega_q850_text: 'Normal call clearing',
                     lega_q850_params: 'sparam1; sparam2=test; sparam3=test',
                     legb_q850_cause: 32,
                     legb_q850_text: 'test',
                     legb_q850_params: 'sparam1',
                     lega_ss_status_id: -1,
                     legb_ss_status_id: 2
                   )

    expect(cdr.lega_identity).to match [
      { header: { alg: 'ES256', ppt: 'shaken', typ: 'passport', x5u: 'http://127.0.0.1/share/test.pem' }, parsed: true, payload: { attest: 'C', dest: { tn: '456', uri: 'sip:456' }, iat: 1_622_830_203, orig: { tn: '123', uri: 'sip:123' }, origid: '8-000F7304-60BA6C7B000B6828-A43657C0' }, verified: true },
      { error_code: 4, error_reason: 'Incorrect Identity Header Value', parsed: false },
      { error_code: -1, error_reason: 'certificate is not available', header: { alg: 'ES256', ppt: 'shaken', typ: 'passport', x5u: 'http://127.0.0.1/share/test2.pem' }, parsed: true, payload: { attest: 'C', dest: { tn: '13' }, iat: 1_622_831_252, orig: { tn: '42' }, origid: '8-000F7304-60BA7094000207EC-2B5F27C0' }, verified: false }
    ].map(&:deep_stringify_keys)
  end

  context 'When call duration =0 and price already rounded' do
    before do
      # always UP, precision 4
      System::CdrConfig.take!.update!(
        customer_amount_round_mode_id: 2,
        customer_amount_round_precision: 4,
        vendor_amount_round_mode_id: 2,
        vendor_amount_round_precision: 4
      )
    end

    let(:i_time_data) do
      {
        "time_start": time_start.to_f,
        "leg_b_time": leg_b_time.to_f,
        "time_connect": nil,
        "time_end": time_end.to_f,
        "time_1xx": time_1xx.to_f,
        "time_18x": time_18x.to_f,
        "time_limit": 7200,
        "isup_propagation_delay": 0
      }.to_json
    end

    let(:writecdr_parameters) do
      %(
          't',
          '10',
          '3',
          '4',
          't',
          '1',
          '127.0.0.3',
          '1015',
          '127.0.0.2',
          '1926',
          '1',
          '127.0.0.5',
          '1036',
          '127.0.0.4',
          '5065',
          'sip:ruri@example.com:8090;transport=TCP',
          'sip:outbound-proxy@example.com:8090;transport=TCP',
          '#{i_time_data}',
          'f',
          '200',
          'Bye',
          '3',
          '200',
          'Bye',
          '200',
          'Bye',
          'dhgxlgaifhhmovy@elo',
          '08889A81-5ABE27EE000480C0-EE666700',
          '73F4856A-5ABE27EE00047ECE-CD83B700',
          '99F4856A-5ABE27EE00047ECE-CD83B711',
          '/var/spool/sems/dump/73F4856A-5ABE27EE00047ECE-CD83B700_10.pcap',
          '0',
          'f',
          '{}',
          '#{i_rtp_statistics}',
          '',
          '',
          '[]',
          3::smallint,
          1551231112::bigint,
          NULL,
          '{"core":"1.7.60-4","yeti":"1.7.30-1","aleg":"Twinkle/1.10.1","bleg":"Localhost Media Gateway"}',
          'f',
          '#{i_dynamic_fields}',
          '{"p_charge_info":"sip:p-charge-info@example.com/uri","reason":{ "q850_cause":16,"q850_text":"Normal call clearing", "q850_params":"sparam1; sparam2=test; sparam3=test"}}',
          '{"v_info":"sip:p-charge-info@example.com/uri","reason":{ "q850_cause":32,"q850_text":"test", "q850_params":"sparam1"}}',
          '[{"header":{"alg":"ES256","ppt":"shaken","typ":"passport","x5u":"http://127.0.0.1/share/test.pem"},"parsed":true,"payload":{"attest":"C","dest":{"tn":"456","uri":"sip:456"},"iat":1622830203,"orig":{"tn":"123","uri":"sip:123"},"origid":"8-000F7304-60BA6C7B000B6828-A43657C0"},"verified":true},{"error_code":4,"error_reason":"Incorrect Identity Header Value","parsed":false},{"error_code":-1,"error_reason":"certificate is not available","header":{"alg":"ES256","ppt":"shaken","typ":"passport","x5u":"http://127.0.0.1/share/test2.pem"},"parsed":true,"payload":{"attest":"C","dest":{"tn":"13"},"iat":1622831252,"orig":{"tn":"42"},"origid":"8-000F7304-60BA7094000207EC-2B5F27C0"},"verified":false}]'
        )
    end
    it 'customer amount' do
      expect { subject }.to change { Cdr::Cdr.count }.by(1)
      expect(Cdr::Cdr.last.customer_price).to eq(0)
      expect(Cdr::Cdr.last.customer_price_no_vat).to eq(0)
      expect(Cdr::Cdr.last.vendor_price).to eq(0)
    end
  end

  context 'When customer round mode=2' do
    before do
      # always UP, precision 4
      System::CdrConfig.take!.update!(
        customer_amount_round_mode_id: 2,
        customer_amount_round_precision: 4,
        vendor_amount_round_mode_id: 2,
        vendor_amount_round_precision: 4
      )
    end

    it 'customer amount' do
      # 560 sec duration, 10s first interval, 11s next, rates = 0.0001/60*10 , 0.0001/60*11
      # (50 × 11) + (1 × 10) = 560s,
      # 0.0001/60*11 * 50 + 0.0001/60*10 = 0,0009333333333
      expect { subject }.to change { Cdr::Cdr.count }.by(1)
      expect(Cdr::Cdr.last.customer_price).to eq(0.0012) # 0,0009333333333 * 1.23(vat) = 0,001148000000, rounded UP to 4 digits
      expect(Cdr::Cdr.last.customer_price_no_vat).to eq(0.001) # 0,0009333333333 rounded UP to 4 digits
      expect(Cdr::Cdr.last.vendor_price).to eq(9.5167)
    end
  end

  context 'When customer round mode=3' do
    before do
      # always DOWN, precision 4
      System::CdrConfig.take!.update!(
        customer_amount_round_mode_id: 3,
        customer_amount_round_precision: 4,
        vendor_amount_round_mode_id: 3,
        vendor_amount_round_precision: 4
      )
    end

    it 'customer amount' do
      expect { subject }.to change { Cdr::Cdr.count }.by(1)
      expect(Cdr::Cdr.last.customer_price).to eq(0.0011) # 0,0009333333333 * 1.23(vat) = 0,001148000000, rounded DOWN to 4 digits
      expect(Cdr::Cdr.last.customer_price_no_vat).to eq(0.0009) # 0,0009333333333 rounded DOWN to 4 digits
      expect(Cdr::Cdr.last.vendor_price).to eq(9.5166)
    end
  end

  context 'When customer round mode=4' do
    before do
      # MATH rules, precision 4
      System::CdrConfig.take!.update!(
        customer_amount_round_mode_id: 3,
        customer_amount_round_precision: 4,
        vendor_amount_round_mode_id: 3,
        vendor_amount_round_precision: 4
      )
    end

    it 'customer amount' do
      expect { subject }.to change { Cdr::Cdr.count }.by(1)
      expect(Cdr::Cdr.last.customer_price).to eq(0.0011) # 0,0009333333333 * 1.23(vat) = 0,001148000000, rounded MATH to 4 digits
      expect(Cdr::Cdr.last.customer_price_no_vat).to eq(0.0009) # 0,0009333333333 rounded MATH to 4 digits
      expect(Cdr::Cdr.last.vendor_price).to eq(9.5166)
    end
  end

  context 'When metadata is null' do
    let(:metadata) { nil }

    it 'metadata is null in CDR' do
      expect { subject }.to change { Cdr::Cdr.count }.by(1)
      expect(Cdr::Cdr.last.metadata).to eq(nil)
    end
  end

  context 'When metadata is valid json' do
    let(:metadata) do
      '{"lua_response":"test_response"}'
    end

    it 'metadata is json in CDR' do
      expect { subject }.to change { Cdr::Cdr.count }.by(1)
      expect(Cdr::Cdr.last.metadata.to_json).to eq(metadata)
    end
  end

  context 'When metadata is not valid json' do
    let(:metadata) do
      '{"lua_responsedwww}'
    end

    it 'writecdr raising exception' do
      expect { subject }.to raise_error(ActiveRecord::StatementInvalid, /PG::InvalidTextRepresentation: ERROR:  invalid input syntax for type json(.*)/)
    end
  end

  context 'When lega_remote_port  is zero' do
    let(:lega_remote_port) { 0 }

    it 'null should be saved to CDR' do
      expect { subject }.to change { Cdr::Cdr.count }.by(1)
      expect(Cdr::Cdr.last.sign_orig_port).to eq(nil)
    end
  end

  context 'When lega_local_port  is zero' do
    let(:lega_local_port) { 0 }

    it 'null should be saved to CDR' do
      expect { subject }.to change { Cdr::Cdr.count }.by(1)
      expect(Cdr::Cdr.last.sign_orig_local_port).to eq(nil)
    end
  end

  context 'When legb_remote_port  is zero' do
    let(:legb_remote_port) { 0 }

    it 'null should be saved to CDR' do
      expect { subject }.to change { Cdr::Cdr.count }.by(1)
      expect(Cdr::Cdr.last.sign_term_port).to eq(nil)
    end
  end

  context 'When legb_local_port  is zero' do
    let(:legb_local_port) { 0 }

    it 'null should be saved to CDR' do
      expect { subject }.to change { Cdr::Cdr.count }.by(1)
      expect(Cdr::Cdr.last.sign_term_local_port).to eq(nil)
    end
  end
end
