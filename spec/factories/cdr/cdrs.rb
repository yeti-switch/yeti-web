# frozen_string_literal: true

# == Schema Information
#
# Table name: cdr.cdr
#
#  id                              :bigint(8)        not null, primary key
#  audio_recorded                  :boolean
#  auth_orig_ip                    :inet
#  auth_orig_port                  :integer(4)
#  core_version                    :string
#  customer_acc_vat                :decimal(, )
#  customer_account_check_balance  :boolean
#  customer_auth_external_type     :string
#  customer_auth_name              :string
#  customer_duration               :integer(4)
#  customer_price                  :decimal(, )
#  customer_price_no_vat           :decimal(, )
#  destination_fee                 :decimal(, )
#  destination_initial_interval    :integer(4)
#  destination_initial_rate        :decimal(, )
#  destination_next_interval       :integer(4)
#  destination_next_rate           :decimal(, )
#  destination_prefix              :string
#  destination_reverse_billing     :boolean
#  dialpeer_fee                    :decimal(, )
#  dialpeer_initial_interval       :integer(4)
#  dialpeer_initial_rate           :decimal(, )
#  dialpeer_next_interval          :integer(4)
#  dialpeer_next_rate              :decimal(, )
#  dialpeer_prefix                 :string
#  dialpeer_reverse_billing        :boolean
#  diversion_in                    :string
#  diversion_out                   :string
#  dst_prefix_in                   :string
#  dst_prefix_out                  :string
#  dst_prefix_routing              :string
#  duration                        :integer(4)
#  early_media_present             :boolean
#  from_domain                     :string
#  global_tag                      :string
#  internal_disconnect_code        :integer(4)
#  internal_disconnect_reason      :string
#  is_last_cdr                     :boolean
#  is_redirected                   :boolean
#  lega_disconnect_code            :integer(4)
#  lega_disconnect_reason          :string
#  lega_identity                   :jsonb
#  lega_q850_cause                 :integer(2)
#  lega_q850_params                :string
#  lega_q850_text                  :string
#  lega_user_agent                 :string
#  legb_disconnect_code            :integer(4)
#  legb_disconnect_reason          :string
#  legb_local_tag                  :string
#  legb_outbound_proxy             :string
#  legb_q850_cause                 :integer(2)
#  legb_q850_params                :string
#  legb_q850_text                  :string
#  legb_ruri                       :string
#  legb_user_agent                 :string
#  local_tag                       :string
#  lrn                             :string
#  metadata                        :jsonb
#  p_charge_info_in                :string
#  pai_in                          :string
#  pai_out                         :string
#  pdd                             :float
#  ppi_in                          :string
#  ppi_out                         :string
#  privacy_in                      :string
#  privacy_out                     :string
#  profit                          :decimal(, )
#  routing_attempt                 :integer(4)
#  routing_delay                   :float
#  routing_tag_ids                 :integer(2)       is an Array
#  rpid_in                         :string
#  rpid_out                        :string
#  rpid_privacy_in                 :string
#  rpid_privacy_out                :string
#  rtt                             :float
#  ruri_domain                     :string
#  sign_orig_ip                    :string
#  sign_orig_local_ip              :string
#  sign_orig_local_port            :integer(4)
#  sign_orig_port                  :integer(4)
#  sign_term_ip                    :string
#  sign_term_local_ip              :string
#  sign_term_local_port            :integer(4)
#  sign_term_port                  :integer(4)
#  src_name_in                     :string
#  src_name_out                    :string
#  src_prefix_in                   :string
#  src_prefix_out                  :string
#  src_prefix_routing              :string
#  success                         :boolean
#  time_connect                    :timestamptz
#  time_end                        :timestamptz
#  time_start                      :timestamptz      not null
#  to_domain                       :string
#  uuid                            :uuid
#  vendor_duration                 :integer(4)
#  vendor_price                    :decimal(, )
#  yeti_version                    :string
#  auth_orig_transport_protocol_id :integer(2)
#  customer_acc_external_id        :bigint(8)
#  customer_acc_id                 :integer(4)
#  customer_auth_external_id       :bigint(8)
#  customer_auth_id                :integer(4)
#  customer_external_id            :bigint(8)
#  customer_id                     :integer(4)
#  customer_invoice_id             :integer(4)
#  destination_id                  :integer(4)
#  destination_rate_policy_id      :integer(4)
#  dialpeer_id                     :integer(4)
#  disconnect_initiator_id         :integer(4)
#  dst_area_id                     :integer(4)
#  dst_country_id                  :integer(4)
#  dst_network_id                  :integer(4)
#  dump_level_id                   :integer(2)
#  failed_resource_id              :bigint(8)
#  failed_resource_type_id         :integer(2)
#  internal_disconnect_code_id     :integer(2)
#  lega_ss_status_id               :integer(2)
#  legb_ss_status_id               :integer(2)
#  lnp_database_id                 :integer(2)
#  node_id                         :integer(4)
#  orig_call_id                    :string
#  orig_gw_external_id             :bigint(8)
#  orig_gw_id                      :integer(4)
#  package_counter_id              :bigint(8)
#  pop_id                          :integer(4)
#  rateplan_id                     :integer(4)
#  routing_group_id                :integer(4)
#  routing_plan_id                 :integer(4)
#  sign_orig_transport_protocol_id :integer(2)
#  sign_term_transport_protocol_id :integer(2)
#  src_area_id                     :integer(4)
#  src_country_id                  :integer(4)
#  src_network_id                  :integer(4)
#  term_call_id                    :string
#  term_gw_external_id             :bigint(8)
#  term_gw_id                      :integer(4)
#  vendor_acc_external_id          :bigint(8)
#  vendor_acc_id                   :integer(4)
#  vendor_external_id              :bigint(8)
#  vendor_id                       :integer(4)
#  vendor_invoice_id               :integer(4)
#
# Indexes
#
#  cdr_customer_acc_external_id_time_start_idx  (customer_acc_external_id,time_start) WHERE is_last_cdr
#  cdr_customer_acc_id_time_start_idx1          (customer_acc_id,time_start)
#  cdr_customer_id_time_start_idx               (customer_id,time_start)
#  cdr_id_idx                                   (id)
#  cdr_time_start_idx                           (time_start)
#  cdr_vendor_id_time_start_idx                 (vendor_id,time_start)
#
FactoryBot.define do
  factory :cdr, class: 'Cdr::Cdr' do
    uuid                         { SecureRandom.uuid }
    is_last_cdr                  { true }
    time_start                   { 1.minute.ago }
    time_connect                 { 1.minute.ago }
    time_end                     { 30.seconds.ago }
    duration                     { 30 }
    success                      { true }
    destination_initial_interval { 30 }
    destination_initial_rate     { 10.50 }
    destination_next_interval    { 60 }
    destination_next_rate        { 8.20 }
    destination_fee              { 3.15 }
    customer_price               { 2.00 }
    src_name_in                  { 'Src name In' }
    src_prefix_in                { '123' }
    from_domain                  { 'From Domain' }
    dst_prefix_in                { '456' }
    to_domain                    { 'To Domain' }
    ruri_domain                  { 'rURI Domain' }
    diversion_in                 { 'Deversion In' }
    local_tag                    { 'EU' }
    lega_disconnect_code         { 200 }
    lega_disconnect_reason       { 201 }
    auth_orig_ip                 { '127.0.0.1' }
    auth_orig_port               { 8080 }
    src_prefix_routing           { 'SRC Prefix Routing' }
    dst_prefix_routing           { 'DST Prefix Routing' }
    destination_prefix           { 'Destination Prefix' }

    auth_orig_transport_protocol { Equipment::TransportProtocol.take }

    # association :customer # customer_id
    association :customer_acc, factory: :account # customer_acc_id
    association :vendor_acc, factory: :account

    before(:create) do |record, _evaluator|
      # Create partition for current+next monthes if not exists
      Cdr::Cdr.add_partition_for(record.time_start.utc)

      # link Customer from associated Account
      unless record.customer_id
        record.customer_id = record.customer_acc.contractor_id
      end

      # link Vendor from associated Account
      unless record.vendor_id
        record.vendor_id = record.vendor_acc.contractor_id
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
