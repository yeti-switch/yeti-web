# frozen_string_literal: true

class Api::Rest::Customer::V1::CdrResource < Api::Rest::Customer::V1::BaseResource
  model_name 'Cdr::Cdr'

  def self.default_sort
    [{ field: 'time_start', direction: :desc }]
  end

  attributes :time_start,
             :time_connect,
             :time_end,
             :duration,
             :success,
             :destination_initial_interval,
             :destination_initial_rate,
             :destination_next_interval,
             :destination_next_rate,
             :destination_fee,
             :customer_price,
             :src_name_in,
             :src_prefix_in,
             :from_domain,
             :dst_prefix_in,
             :to_domain,
             :ruri_domain,
             :diversion_in,
             :local_tag,
             :lega_disconnect_code,
             :lega_disconnect_reason,
             :lega_rx_payloads,
             :lega_tx_payloads,
             :auth_orig_transport_protocol_id,
             :auth_orig_ip,
             :auth_orig_port,
             :lega_rx_bytes,
             :lega_tx_bytes,
             :lega_rx_decode_errs,
             :lega_rx_no_buf_errs,
             :lega_rx_parse_errs,
             :src_prefix_routing,
             :dst_prefix_routing,
             :destination_prefix

  has_one :auth_orig_transport_protocol, class_name: 'TransportProtocol'
  has_one :account, class_name: 'Account'

  filter :is_last_cdr, default: true

  filters :success, :src_prefix_routing, :dst_prefix_routing, :duration,
          :lega_disconnect_code, :lega_disconnect_reason, :src_prefix_in,
          :dst_prefix_in, :diversion_in, :src_name_in, :local_tag

  ransack_filter :time_start, type: :datetime
  ransack_filter :destination_next_rate, type: :number
  ransack_filter :destination_fee, type: :number
  ransack_filter :dialpeer_next_rate, type: :number
  ransack_filter :dialpeer_fee, type: :number
  ransack_filter :time_limit, type: :string
  ransack_filter :internal_disconnect_code, type: :number
  ransack_filter :internal_disconnect_reason, type: :string
  ransack_filter :disconnect_initiator_id, type: :number
  ransack_filter :customer_price, type: :number
  ransack_filter :vendor_price, type: :number
  ransack_filter :duration, type: :number
  ransack_filter :success, type: :boolean
  ransack_filter :profit, type: :number
  ransack_filter :dst_prefix_in, type: :string
  ransack_filter :dst_prefix_out, type: :string
  ransack_filter :src_prefix_in, type: :string
  ransack_filter :src_prefix_out, type: :string
  ransack_filter :time_connect, type: :datetime
  ransack_filter :time_end, type: :datetime
  ransack_filter :sign_orig_ip, type: :string
  ransack_filter :sign_orig_port, type: :number
  ransack_filter :sign_orig_local_ip, type: :string
  ransack_filter :sign_orig_local_port, type: :number
  ransack_filter :sign_term_ip, type: :string
  ransack_filter :sign_term_port, type: :number
  ransack_filter :sign_term_local_ip, type: :string
  ransack_filter :sign_term_local_port, type: :number
  ransack_filter :orig_call_id, type: :string
  ransack_filter :term_call_id, type: :string
  ransack_filter :vendor_invoice_id, type: :number
  ransack_filter :customer_invoice_id, type: :number
  ransack_filter :local_tag, type: :string
  ransack_filter :destination_initial_rate, type: :number
  ransack_filter :dialpeer_initial_rate, type: :number
  ransack_filter :destination_initial_interval, type: :number
  ransack_filter :destination_next_interval, type: :number
  ransack_filter :dialpeer_initial_interval, type: :number
  ransack_filter :dialpeer_next_interval, type: :number
  ransack_filter :routing_attempt, type: :number
  ransack_filter :lega_disconnect_code, type: :number
  ransack_filter :lega_disconnect_reason, type: :string
  ransack_filter :node_id, type: :number
  ransack_filter :src_name_in, type: :string
  ransack_filter :src_name_out, type: :string
  ransack_filter :diversion_in, type: :string
  ransack_filter :diversion_out, type: :string
  ransack_filter :lega_rx_payloads, type: :string
  ransack_filter :lega_tx_payloads, type: :string
  ransack_filter :legb_rx_payloads, type: :string
  ransack_filter :legb_tx_payloads, type: :string
  ransack_filter :legb_disconnect_code, type: :number
  ransack_filter :legb_disconnect_reason, type: :string
  ransack_filter :dump_level_id, type: :number
  ransack_filter :auth_orig_ip, type: :inet
  ransack_filter :auth_orig_port, type: :number
  ransack_filter :lega_rx_bytes, type: :number
  ransack_filter :lega_tx_bytes, type: :number
  ransack_filter :legb_rx_bytes, type: :number
  ransack_filter :legb_tx_bytes, type: :number
  ransack_filter :global_tag, type: :string
  ransack_filter :src_country_id, type: :number
  ransack_filter :src_network_id, type: :number
  ransack_filter :dst_country_id, type: :number
  ransack_filter :dst_network_id, type: :number
  ransack_filter :lega_rx_decode_errs, type: :number
  ransack_filter :lega_rx_no_buf_errs, type: :number
  ransack_filter :lega_rx_parse_errs, type: :number
  ransack_filter :legb_rx_decode_errs, type: :number
  ransack_filter :legb_rx_no_buf_errs, type: :number
  ransack_filter :legb_rx_parse_errs, type: :number
  ransack_filter :src_prefix_routing, type: :string
  ransack_filter :dst_prefix_routing, type: :string
  ransack_filter :routing_delay, type: :number
  ransack_filter :pdd, type: :number
  ransack_filter :rtt, type: :number
  ransack_filter :early_media_present, type: :boolean
  ransack_filter :lnp_database_id, type: :number
  ransack_filter :lrn, type: :string
  ransack_filter :destination_prefix, type: :string
  ransack_filter :dialpeer_prefix, type: :string
  ransack_filter :audio_recorded, type: :boolean
  ransack_filter :ruri_domain, type: :string
  ransack_filter :to_domain, type: :string
  ransack_filter :from_domain, type: :string
  ransack_filter :src_area_id, type: :number
  ransack_filter :dst_area_id, type: :number
  ransack_filter :auth_orig_transport_protocol_id, type: :number
  ransack_filter :sign_orig_transport_protocol_id, type: :number
  ransack_filter :sign_term_transport_protocol_id, type: :number
  ransack_filter :core_version, type: :string
  ransack_filter :yeti_version, type: :string
  ransack_filter :lega_user_agent, type: :string
  ransack_filter :legb_user_agent, type: :string
  ransack_filter :uuid, type: :uuid
  ransack_filter :pai_in, type: :string
  ransack_filter :ppi_in, type: :string
  ransack_filter :privacy_in, type: :string
  ransack_filter :rpid_in, type: :string
  ransack_filter :rpid_privacy_in, type: :string
  ransack_filter :pai_out, type: :string
  ransack_filter :ppi_out, type: :string
  ransack_filter :privacy_out, type: :string
  ransack_filter :rpid_out, type: :string
  ransack_filter :rpid_privacy_out, type: :string
  ransack_filter :destination_reverse_billing, type: :boolean
  ransack_filter :dialpeer_reverse_billing, type: :boolean
  ransack_filter :is_redirected, type: :boolean
  ransack_filter :customer_account_check_balance, type: :boolean
  ransack_filter :customer_external_id, type: :number
  ransack_filter :customer_auth_external_id, type: :number
  ransack_filter :customer_acc_vat, type: :number
  ransack_filter :customer_acc_external_id, type: :number
  ransack_filter :vendor_external_id, type: :number
  ransack_filter :vendor_acc_external_id, type: :number
  ransack_filter :orig_gw_external_id, type: :number
  ransack_filter :term_gw_external_id, type: :number
  ransack_filter :failed_resource_type_id, type: :number
  ransack_filter :failed_resource_id, type: :number
  ransack_filter :customer_price_no_vat, type: :number
  ransack_filter :customer_duration, type: :number
  ransack_filter :vendor_duration, type: :number

  association_uuid_filter :account_id, column: :customer_acc_id, class_name: 'Account'

  def self.apply_allowed_accounts(records, options)
    context = options[:context]
    scope = records.where_customer(context[:customer_id])
    scope = scope.where_account(context[:allowed_account_ids]) if context[:allowed_account_ids].present?
    scope
  end
end
