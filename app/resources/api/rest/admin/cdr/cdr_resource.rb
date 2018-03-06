class Api::Rest::Admin::Cdr::CdrResource < ::BaseResource
  immutable
  model_name 'Cdr::Cdr'
  paginator :paged

  module CONST
    ROOT_NAMESPACE_RELATIONS = %w(
      Rateplan Dialpeer Pop RoutingGroup Destination CustomersAuth Contractor Account Gateway DestinationRatePolicy RoutingPlan
    ).freeze
    SYSTEM_NAMESPACE_RELATIONS = %w(Country Network)
    freeze
  end

  attributes :time_start,
    :destination_next_rate,
    :destination_fee,
    :dialpeer_next_rate,
    :dialpeer_fee,
    :time_limit,
    :internal_disconnect_code,
    :internal_disconnect_reason,
    :disconnect_initiator_id,
    :customer_price,
    :vendor_price,
    :duration,
    :success,
    :profit,
    :dst_prefix_in,
    :dst_prefix_out,
    :src_prefix_in,
    :src_prefix_out,
    :time_connect,
    :time_end,
    :sign_orig_ip,
    :sign_orig_port,
    :sign_orig_local_ip,
    :sign_orig_local_port,
    :sign_term_ip,
    :sign_term_port,
    :sign_term_local_ip,
    :sign_term_local_port,
    :orig_call_id,
    :term_call_id,
    :vendor_invoice_id,
    :customer_invoice_id,
    :local_tag,
    :destination_initial_rate,
    :dialpeer_initial_rate,
    :destination_initial_interval,
    :destination_next_interval,
    :dialpeer_initial_interval,
    :dialpeer_next_interval,
    :routing_attempt,
    :is_last_cdr,
    :lega_disconnect_code,
    :lega_disconnect_reason,
    :node_id,
    :src_name_in,
    :src_name_out,
    :diversion_in,
    :diversion_out,
    :lega_rx_payloads,
    :lega_tx_payloads,
    :legb_rx_payloads,
    :legb_tx_payloads,
    :legb_disconnect_code,
    :legb_disconnect_reason,
    :dump_level_id,
    :auth_orig_ip,
    :auth_orig_port,
    :lega_rx_bytes,
    :lega_tx_bytes,
    :legb_rx_bytes,
    :legb_tx_bytes,
    :global_tag,
    :dst_country_id,
    :dst_network_id,
    :lega_rx_decode_errs,
    :lega_rx_no_buf_errs,
    :lega_rx_parse_errs,
    :legb_rx_decode_errs,
    :legb_rx_no_buf_errs,
    :legb_rx_parse_errs,
    :src_prefix_routing,
    :dst_prefix_routing,
    :routing_delay,
    :pdd,
    :rtt,
    :early_media_present,
    :lnp_database_id,
    :lrn,
    :destination_prefix,
    :dialpeer_prefix,
    :audio_recorded,
    :ruri_domain,
    :to_domain,
    :from_domain,
    :routing_tag_id,
    :src_area_id,
    :dst_area_id,
    :auth_orig_transport_protocol_id,
    :sign_orig_transport_protocol_id,
    :sign_term_transport_protocol_id,
    :core_version,
    :yeti_version,
    :lega_user_agent,
    :legb_user_agent,
    :uuid,
    :pai_in,
    :ppi_in,
    :privacy_in,
    :rpid_in,
    :rpid_privacy_in,
    :pai_out,
    :ppi_out,
    :privacy_out,
    :rpid_out,
    :rpid_privacy_out,
    :destination_reverse_billing,
    :dialpeer_reverse_billing,
    :is_redirected,
    :customer_account_check_balance,
    :customer_external_id,
    :customer_auth_external_id,
    :customer_acc_vat,
    :customer_acc_external_id,
    :routing_tag_ids,
    :vendor_external_id,
    :vendor_acc_external_id,
    :orig_gw_external_id,
    :term_gw_external_id,
    :failed_resource_type_id,
    :failed_resource_id,
    :customer_price_no_vat,
    :customer_duration,
    :vendor_duration

  has_one :rateplan
  has_one :dialpeer
  has_one :pop
  has_one :routing_group
  has_one :routing_plan, class_name: 'RoutingPlan'
  has_one :destination
  has_one :customer_auth
  has_one :destination_rate_policy
  has_one :vendor, class_name: 'Contractor'
  has_one :customer, class_name: 'Contractor'
  has_one :customer_acc, class_name: 'Account'
  has_one :vendor_acc, class_name: 'Account'
  has_one :orig_gw, class_name: 'Gateway'
  has_one :term_gw, class_name: 'Gateway'
  has_one :country, relation_name: :dst_country, foreign_key_on: :dst_country_id
  has_one :network, relation_name: :dst_network, foreign_key_on: :dst_network_id

  filter :customer_auth_external_id
  filter :failed_resource_type_id
  filter :success
  filter :src_prefix_in, apply: ->(records, values, _options) do
    _scope = records
    values.each do |v|
      _scope = _scope.where("src_prefix_in LIKE ?", "%#{v}%")
    end
    _scope
  end
  filter :dst_prefix_in, apply: ->(records, values, _options) do
    _scope = records
    values.each do |v|
      _scope = _scope.where("dst_prefix_in LIKE ?", "%#{v}%")
    end
    _scope
  end
  filter :src_prefix_routing, apply: ->(records, values, _options) do
    _scope = records
    values.each do |v|
      _scope = _scope.where("src_prefix_routing LIKE ?", "%#{v}%")
    end
    _scope
  end
  filter :time_start_greater_or_eq, apply: ->(records, values, _options) do
    records.where('time_start >= ?', values[0])
  end
  filter :time_start_less_or_eq, apply: ->(records, values, _options) do
    records.where('time_start <= ?', values[0])
  end
  filter :customer_acc_external_id

  # add supporting associations from non cdr namespaces
  def self.resource_for(type)
    if type.in?(CONST::ROOT_NAMESPACE_RELATIONS)
      "Api::Rest::Admin::#{type}Resource".safe_constantize
    elsif type.in?(CONST::SYSTEM_NAMESPACE_RELATIONS)
      "Api::Rest::Admin::System::#{type}Resource".safe_constantize
    else
      super
    end
  end
end
