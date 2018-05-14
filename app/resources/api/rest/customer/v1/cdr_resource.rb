class Api::Rest::Customer::V1::CdrResource < Api::Rest::Customer::V1::BaseResource
  model_name 'Cdr::Cdr'

  key_type :uuid
  primary_key :uuid

  def self.default_sort
    [{field: 'time_start', direction: :desc}]
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

  filter :is_last_cdr, default: true

  filters :success, :src_prefix_routing, :dst_prefix_routing, :duration,
          :lega_disconnect_code, :lega_disconnect_reason, :src_prefix_in,
          :dst_prefix_in, :diversion_in, :src_name_in, :local_tag

  ransack_filter :time_start_gteq
  ransack_filter :time_start_lteq

  # TODO: move to BaseResource
  def self.records(options = {})
    apply_allowed_accounts(super(options), options)
  end

  def self.apply_allowed_accounts(_records, options)
    context = options[:context]
    scope = _records.where_customer(context[:customer_id])
    scope = scope.where_account(context[:allowed_account_ids]) if context[:allowed_account_ids].present?
    scope
  end
end
