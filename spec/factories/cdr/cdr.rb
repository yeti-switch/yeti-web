# frozen_string_literal: true

FactoryGirl.define do
  factory :cdr, class: Cdr::Cdr do
    uuid                         { SecureRandom.uuid }
    is_last_cdr                  true
    time_start                   { 1.minute.ago }
    time_connect                 { 1.minute.ago }
    time_end                     { 30.seconds.ago }
    duration                     30
    success                      true
    destination_initial_interval 30
    destination_initial_rate     10.50
    destination_next_interval    60
    destination_next_rate        8.20
    destination_fee              3.15
    customer_price               2.00
    src_name_in                  'Src name In'
    src_prefix_in                '123'
    from_domain                  'From Domain'
    dst_prefix_in                '456'
    to_domain                    'To Domain'
    ruri_domain                  'rURI Domain'
    diversion_in                 'Deversion In'
    local_tag                    'EU'
    lega_disconnect_code         200
    lega_disconnect_reason       201
    lega_rx_payloads             'LegA RX Payloads'
    lega_tx_payloads             'LegA TX Payloads'
    auth_orig_ip                 '127.0.0.1'
    auth_orig_port               8080
    lega_rx_bytes                256
    lega_tx_bytes                1024
    lega_rx_decode_errs          0
    lega_rx_no_buf_errs          0
    lega_rx_parse_errs           0
    src_prefix_routing           'SRC Prefix Routing'
    dst_prefix_routing           'DST Prefix Routing'
    destination_prefix           'Destination Prefix'

    auth_orig_transport_protocol { Equipment::TransportProtocol.take }

    # association :customer # customer_id
    association :customer_acc, factory: :account # customer_acc_id

    before(:create) do |record, _evaluator|
      # Create partition for current+next monthes if not exists
      Cdr::Cdr.add_partition_for(record.time_start)

      # link Customer from associated Account
      unless record.customer_id
        record.customer_id = record.customer_acc.contractor_id
      end
    end

    trait :with_id do
      id { Cdr::Cdr.connection.select_value("SELECT nextval('cdr.cdr_id_seq')").to_i }
    end

    trait :with_id_and_uuid do
      id { Cdr::Cdr.connection.select_value("SELECT nextval('cdr.cdr_id_seq')").to_i }
      uuid { SecureRandom.uuid }
    end
  end
end
