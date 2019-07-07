# frozen_string_literal: true

# == Schema Information
#
# Table name: cdr.cdr
#
#  id                              :integer          not null, primary key
#  customer_id                     :integer
#  vendor_id                       :integer
#  customer_acc_id                 :integer
#  vendor_acc_id                   :integer
#  customer_auth_id                :integer
#  destination_id                  :integer
#  dialpeer_id                     :integer
#  orig_gw_id                      :integer
#  term_gw_id                      :integer
#  routing_group_id                :integer
#  rateplan_id                     :integer
#  destination_next_rate           :decimal(, )
#  destination_fee                 :decimal(, )
#  dialpeer_next_rate              :decimal(, )
#  dialpeer_fee                    :decimal(, )
#  time_limit                      :string
#  internal_disconnect_code        :integer
#  internal_disconnect_reason      :string
#  disconnect_initiator_id         :integer
#  customer_price                  :decimal(, )
#  vendor_price                    :decimal(, )
#  duration                        :integer
#  success                         :boolean
#  profit                          :decimal(, )
#  dst_prefix_in                   :string
#  dst_prefix_out                  :string
#  src_prefix_in                   :string
#  src_prefix_out                  :string
#  time_start                      :datetime
#  time_connect                    :datetime
#  time_end                        :datetime
#  sign_orig_ip                    :string
#  sign_orig_port                  :integer
#  sign_orig_local_ip              :string
#  sign_orig_local_port            :integer
#  sign_term_ip                    :string
#  sign_term_port                  :integer
#  sign_term_local_ip              :string
#  sign_term_local_port            :integer
#  orig_call_id                    :string
#  term_call_id                    :string
#  vendor_invoice_id               :integer
#  customer_invoice_id             :integer
#  local_tag                       :string
#  destination_initial_rate        :decimal(, )
#  dialpeer_initial_rate           :decimal(, )
#  destination_initial_interval    :integer
#  destination_next_interval       :integer
#  dialpeer_initial_interval       :integer
#  dialpeer_next_interval          :integer
#  destination_rate_policy_id      :integer
#  routing_attempt                 :integer
#  is_last_cdr                     :boolean
#  lega_disconnect_code            :integer
#  lega_disconnect_reason          :string
#  pop_id                          :integer
#  node_id                         :integer
#  src_name_in                     :string
#  src_name_out                    :string
#  diversion_in                    :string
#  diversion_out                   :string
#  lega_rx_payloads                :string
#  lega_tx_payloads                :string
#  legb_rx_payloads                :string
#  legb_tx_payloads                :string
#  legb_disconnect_code            :integer
#  legb_disconnect_reason          :string
#  dump_level_id                   :integer          default(0), not null
#  auth_orig_ip                    :inet
#  auth_orig_port                  :integer
#  lega_rx_bytes                   :integer
#  lega_tx_bytes                   :integer
#  legb_rx_bytes                   :integer
#  legb_tx_bytes                   :integer
#  global_tag                      :string
#  dst_country_id                  :integer
#  dst_network_id                  :integer
#  lega_rx_decode_errs             :integer
#  lega_rx_no_buf_errs             :integer
#  lega_rx_parse_errs              :integer
#  legb_rx_decode_errs             :integer
#  legb_rx_no_buf_errs             :integer
#  legb_rx_parse_errs              :integer
#  src_prefix_routing              :string
#  dst_prefix_routing              :string
#  routing_plan_id                 :integer
#  routing_delay                   :float
#  pdd                             :float
#  rtt                             :float
#  early_media_present             :boolean
#  lnp_database_id                 :integer
#  lrn                             :string
#  destination_prefix              :string
#  dialpeer_prefix                 :string
#  audio_recorded                  :boolean
#  ruri_domain                     :string
#  to_domain                       :string
#  from_domain                     :string
#  src_area_id                     :integer
#  dst_area_id                     :integer
#  auth_orig_transport_protocol_id :integer
#  sign_orig_transport_protocol_id :integer
#  sign_term_transport_protocol_id :integer
#  core_version                    :string
#  yeti_version                    :string
#  lega_user_agent                 :string
#  legb_user_agent                 :string
#  uuid                            :uuid
#  pai_in                          :string
#  ppi_in                          :string
#  privacy_in                      :string
#  rpid_in                         :string
#  rpid_privacy_in                 :string
#  pai_out                         :string
#  ppi_out                         :string
#  privacy_out                     :string
#  rpid_out                        :string
#  rpid_privacy_out                :string
#  destination_reverse_billing     :boolean
#  dialpeer_reverse_billing        :boolean
#  is_redirected                   :boolean
#  customer_account_check_balance  :boolean
#  customer_external_id            :integer
#  customer_auth_external_id       :integer
#  customer_acc_vat                :decimal(, )
#  customer_acc_external_id        :integer
#  routing_tag_ids                 :integer          is an Array
#  vendor_external_id              :integer
#  vendor_acc_external_id          :integer
#  orig_gw_external_id             :integer
#  term_gw_external_id             :integer
#  failed_resource_type_id         :integer
#  failed_resource_id              :integer
#  customer_price_no_vat           :decimal(, )
#  customer_duration               :integer
#  vendor_duration                 :integer
#  customer_auth_name              :string
#

require 'spec_helper'

RSpec.describe Cdr::Cdr, type: :model do
  before { described_class.destroy_all }
  after { described_class.destroy_all }

  let(:db_connection) { described_class.connection }

  it { expect(described_class.count).to eq(0) }

  describe 'Function "switch.writecdr()"' do
    before do
      # disable rounding
      System::CdrConfig.take!.update!(
        customer_amount_round_mode_id: 1,
        vendor_amount_round_mode_id: 1
      )
    end

    subject do
      db_connection.execute("SELECT switch.writecdr(#{writecdr_parameters});")
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
        '{"lega_rx_payloads":"/pcmu","lega_tx_payloads":"/pcmu","legb_rx_payloads":"/pcmu","legb_tx_payloads":"/pcmu","lega_rx_bytes":153596,"lega_tx_bytes":152736,"legb_rx_bytes":152736,"legb_tx_bytes":153596,"lega_rx_decode_errs":1763,"lega_rx_no_buf_errs":1025,"lega_rx_parse_errs":1710,"legb_rx_decode_errs":1777,"legb_rx_no_buf_errs":1000,"legb_rx_parse_errs":1482}',
        '[]',
        '',
        '',
        '[]',
        3::smallint,
        1551231112::bigint,
        NULL,
        '{"core":"1.7.60-4","yeti":"1.7.30-1","aleg":"Twinkle/1.10.1","bleg":"Localhost Media Gateway"}',
        'f',
        '{"customer_auth_name":"Customer Auth for trunk 1","customer_id":1105,"vendor_id":1755,"customer_acc_id":1886,"vendor_acc_id":32,"customer_auth_id":20084,"destination_id":4201534,"destination_prefix":"","dialpeer_id":1376789,"dialpeer_prefix":"","orig_gw_id":17,"term_gw_id":39,"routing_group_id":22,"rateplan_id":14,"destination_initial_rate":"0.0001","destination_next_rate":"0.0001","destination_initial_interval":60,"destination_next_interval":11,"destination_rate_policy_id":1442,"dialpeer_initial_interval":12,"dialpeer_next_interval":13,"dialpeer_next_rate":"1.0","destination_fee":"0.0","dialpeer_initial_rate":"1.0","dialpeer_fee":"0.0","dst_prefix_in":"380947100008","dst_prefix_out":"echotest","src_prefix_in":"h","src_prefix_out":"380947111223","src_name_in":"","src_name_out":"","diversion_in":"rspec-diversion-in","diversion_out":"rspec-diversion-out","auth_orig_protocol_id":1567,"auth_orig_ip":"127.0.0.1","auth_orig_port":1947,"dst_country_id":222,"dst_network_id":1533,"dst_prefix_routing":"380947100008","src_prefix_routing":"380947111223","routing_plan_id":1,"lrn":"rspec-lrn","lnp_database_id":111,"from_domain":"node-10.yeti-sandbox.localhost","to_domain":"node-10.yeti-sandbox.localhost","ruri_domain":"node-10.yeti-sandbox.localhost","src_area_id":222,"dst_area_id":333,"routing_tag_ids":"{9}","pai_in":"rspec-pai-in","ppi_in":"rspec-ppi-in","privacy_in":"rspec-privacy-in","rpid_in":"rspec-rpid-in","rpid_privacy_in":"rspec-rpid-privacy-in","pai_out":"rspec-pai-out","ppi_out":"rspec-ppi-out","privacy_out":"rspec-privacy-out","rpid_out":"rspec-rpid-out","rpid_privacy_out":"rspec-rpid-privacy-out","customer_acc_check_balance":true,"destination_reverse_billing":false,"dialpeer_reverse_billing":false,"customer_auth_external_id":1504,"customer_external_id":156998,"vendor_external_id":1111,"customer_acc_external_id":156998,"vendor_acc_external_id":2222,"orig_gw_external_id":1,"term_gw_external_id":4444,"customer_acc_vat":"0.0"}'
      )
    end

    it 'creates new CDR-record' do
      expect { subject }.to change { described_class.count }.by(1)
    end

    it 'creates CDR with expected attributes' do
      subject
      expect(described_class.last.attributes.symbolize_keys).to match(
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
        time_limit: '7200',
        internal_disconnect_code: 200,
        internal_disconnect_reason: 'Bye',
        disconnect_initiator_id: 3,
        customer_price: be_within(0.00001).of(0.00094),
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
        sign_orig_ip: '127.0.0.2',
        sign_orig_port: 1926,
        sign_orig_local_ip: '127.0.0.3',
        sign_orig_local_port: 1015,
        sign_term_ip: '127.0.0.4',
        sign_term_port: 5065,
        sign_term_local_ip: '127.0.0.5',
        sign_term_local_port: 1036,
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
        lega_rx_payloads: '/pcmu',
        lega_tx_payloads: '/pcmu',
        legb_rx_payloads: '/pcmu',
        legb_tx_payloads: '/pcmu',
        legb_disconnect_code: 200,
        legb_disconnect_reason: 'Bye',
        dump_level_id: 0,
        auth_orig_ip: '127.0.0.1',
        auth_orig_port: 1947,
        lega_rx_bytes: 153_596,
        lega_tx_bytes: 152_736,
        legb_rx_bytes: 152_736,
        legb_tx_bytes: 153_596,
        global_tag: '',
        dst_country_id: 222,
        dst_network_id: 1533,
        lega_rx_decode_errs: 1763,
        lega_rx_no_buf_errs: 1025,
        lega_rx_parse_errs: 1710,
        legb_rx_decode_errs: 1777,
        legb_rx_no_buf_errs: 1000,
        legb_rx_parse_errs: 1482,
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
        sign_orig_transport_protocol_id: 1,
        sign_term_transport_protocol_id: 1,
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
        customer_acc_vat: 0.0,
        customer_acc_external_id: 156_998,
        routing_tag_ids: [9],
        vendor_external_id: 1111,
        vendor_acc_external_id: 2222,
        orig_gw_external_id: 1,
        term_gw_external_id: 4444,
        failed_resource_type_id: 3,
        failed_resource_id: 1_551_231_112,
        customer_price_no_vat: be_within(0.00001).of(0.00094),
        customer_duration: 566,
        vendor_duration: 571,
        customer_auth_name: 'Customer Auth for trunk 1'
      )
    end

    context 'When call duration =0 and  price already rounded' do
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
          '{"lega_rx_payloads":"/pcmu","lega_tx_payloads":"/pcmu","legb_rx_payloads":"/pcmu","legb_tx_payloads":"/pcmu","lega_rx_bytes":153596,"lega_tx_bytes":152736,"legb_rx_bytes":152736,"legb_tx_bytes":153596,"lega_rx_decode_errs":1763,"lega_rx_no_buf_errs":1025,"lega_rx_parse_errs":1710,"legb_rx_decode_errs":1777,"legb_rx_no_buf_errs":1000,"legb_rx_parse_errs":1482}',
          '[]',
          '',
          '',
          '[]',
          3::smallint,
          1551231112::bigint,
          NULL,
          '{"core":"1.7.60-4","yeti":"1.7.30-1","aleg":"Twinkle/1.10.1","bleg":"Localhost Media Gateway"}',
          'f',
          '{"customer_auth_name":"Customer Auth for trunk 1","customer_id":1105,"vendor_id":1755,"customer_acc_id":1886,"vendor_acc_id":32,"customer_auth_id":20084,"destination_id":4201534,"destination_prefix":"","dialpeer_id":1376789,"dialpeer_prefix":"","orig_gw_id":17,"term_gw_id":39,"routing_group_id":22,"rateplan_id":14,"destination_initial_rate":"0.0001","destination_next_rate":"0.0001","destination_initial_interval":60,"destination_next_interval":11,"destination_rate_policy_id":1442,"dialpeer_initial_interval":12,"dialpeer_next_interval":13,"dialpeer_next_rate":"1.0","destination_fee":"0.0","dialpeer_initial_rate":"1.0","dialpeer_fee":"0.0","dst_prefix_in":"380947100008","dst_prefix_out":"echotest","src_prefix_in":"h","src_prefix_out":"380947111223","src_name_in":"","src_name_out":"","diversion_in":"rspec-diversion-in","diversion_out":"rspec-diversion-out","auth_orig_protocol_id":1567,"auth_orig_ip":"127.0.0.1","auth_orig_port":1947,"dst_country_id":222,"dst_network_id":1533,"dst_prefix_routing":"380947100008","src_prefix_routing":"380947111223","routing_plan_id":1,"lrn":"rspec-lrn","lnp_database_id":111,"from_domain":"node-10.yeti-sandbox.localhost","to_domain":"node-10.yeti-sandbox.localhost","ruri_domain":"node-10.yeti-sandbox.localhost","src_area_id":222,"dst_area_id":333,"routing_tag_ids":"{9}","pai_in":"rspec-pai-in","ppi_in":"rspec-ppi-in","privacy_in":"rspec-privacy-in","rpid_in":"rspec-rpid-in","rpid_privacy_in":"rspec-rpid-privacy-in","pai_out":"rspec-pai-out","ppi_out":"rspec-ppi-out","privacy_out":"rspec-privacy-out","rpid_out":"rspec-rpid-out","rpid_privacy_out":"rspec-rpid-privacy-out","customer_acc_check_balance":true,"destination_reverse_billing":false,"dialpeer_reverse_billing":false,"customer_auth_external_id":1504,"customer_external_id":156998,"vendor_external_id":1111,"customer_acc_external_id":156998,"vendor_acc_external_id":2222,"orig_gw_external_id":1,"term_gw_external_id":4444,"customer_acc_vat":"0.0"}'
        )
      end
      it 'customer amount' do
        expect { subject }.to change { described_class.count }.by(1)
        expect(described_class.last.customer_price).to eq(0)
        expect(described_class.last.vendor_price).to eq(0)
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
        expect { subject }.to change { described_class.count }.by(1)
        expect(described_class.last.customer_price).to eq(0.001)
        expect(described_class.last.vendor_price).to eq(9.5167)
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
        expect { subject }.to change { described_class.count }.by(1)
        expect(described_class.last.customer_price).to eq(0.0009)
        expect(described_class.last.vendor_price).to eq(9.5166)
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
        expect { subject }.to change { described_class.count }.by(1)
        expect(described_class.last.customer_price).to eq(0.0009)
        expect(described_class.last.vendor_price).to eq(9.5166)
      end
    end
  end
end
