# frozen_string_literal: true

class Api::Rest::Admin::Cdr::CdrResource < BaseResource
  immutable
  model_name 'Cdr::Cdr'
  paginator :paged

  module CONST
    ROOT_NAMESPACE_RELATIONS = %w[
      Dialpeer Pop CustomersAuth Contractor Account Gateway RoutingPlan
    ].freeze
    SYSTEM_NAMESPACE_RELATIONS = %w[Country Network].freeze
    ROUTING_NAMESPACE_RELATIONS = %w[Destination Rateplan RoutingGroup].freeze
    freeze
  end

  def self.default_sort
    [{ field: 'time_start', direction: :desc }]
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
             :legb_disconnect_code,
             :legb_disconnect_reason,
             :dump_level_id,
             :auth_orig_ip,
             :auth_orig_port,
             :global_tag,
             :src_network_id,
             :src_country_id,
             :dst_country_id,
             :dst_network_id,
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
             :vendor_duration,
             :destination_rate_policy_id

  has_one :rateplan, class_name: 'Rateplan', force_routed: true
  has_one :dialpeer, force_routed: true
  has_one :pop, force_routed: true
  has_one :routing_group, class_name: 'RoutingGroup', force_routed: true
  has_one :routing_plan, class_name: 'RoutingPlan', force_routed: true
  has_one :destination, class_name: 'Destination', force_routed: true
  has_one :customer_auth, force_routed: true
  has_one :vendor, class_name: 'Contractor', force_routed: true
  has_one :customer, class_name: 'Contractor', force_routed: true
  has_one :customer_acc, class_name: 'Account', force_routed: true
  has_one :vendor_acc, class_name: 'Account', force_routed: true
  has_one :orig_gw, class_name: 'Gateway', force_routed: true
  has_one :term_gw, class_name: 'Gateway', force_routed: true
  has_one :dst_country, class_name: 'Country', force_routed: true
  has_one :dst_network, class_name: 'Network', force_routed: true
  has_one :src_country, class_name: 'Country', force_routed: true
  has_one :src_network, class_name: 'Network', force_routed: true

  filter :customer_auth_external_id_eq, apply: lambda { |records, values, _options|
    records.where(customer_auth_external_id: values)
  }
  filter :failed_resource_type_id_eq, apply: lambda { |records, values, _options|
    records.where(failed_resource_type_id: values)
  }
  filter :success_eq, apply: lambda { |records, values, _options|
    records.where(success: values[0])
  }
  filter :src_prefix_in_contains, apply: lambda { |records, values, _options|
    _scope = records
    values.each do |v|
      _scope = _scope.where('src_prefix_in LIKE ?', "%#{v}%")
    end
    _scope
  }
  filter :dst_prefix_in_contains, apply: lambda { |records, values, _options|
    _scope = records
    values.each do |v|
      _scope = _scope.where('dst_prefix_in LIKE ?', "%#{v}%")
    end
    _scope
  }
  filter :src_prefix_routing_contains, apply: lambda { |records, values, _options|
    _scope = records
    values.each do |v|
      _scope = _scope.where('src_prefix_routing LIKE ?', "%#{v}%")
    end
    _scope
  }
  filter :dst_prefix_routing_contains, apply: lambda { |records, values, _options|
    _scope = records
    values.each do |v|
      _scope = _scope.where('dst_prefix_routing LIKE ?', "%#{v}%")
    end
    _scope
  }
  filter :customer_acc_external_id_eq, apply: lambda { |records, values, _options|
    records.where(customer_acc_external_id: values)
  }

  filter :is_last_cdr_eq, apply: lambda { |records, values, _options|
    records.where(is_last_cdr: values[0])
  }

  filter :dst_country_iso_eq, apply: lambda { |records, values, _options|
    country = System::Country.find_by(iso2: values[0])
    if country
      records.where(dst_country_id: country.id)
    else
      raise JSONAPI::Exceptions::InvalidFilterValue.new(:dst_country_iso_eq, values[0])
    end
  }

  filter :src_country_iso_eq, apply: lambda { |records, values, _options|
    country = System::Country.find_by(iso2: values[0])
    if country
      records.where(src_country_id: country.id)
    else
      raise JSONAPI::Exceptions::InvalidFilterValue.new(:scr_country_iso_eq, values[0])
    end
  }

  filter :routing_tag_ids_include, apply: lambda { |records, values, _options|
    records.routing_tag_ids_include(values[0])
  }

  filter :routing_tag_ids_exclude, apply: lambda { |records, values, _options|
    records.routing_tag_ids_exclude(values[0])
  }

  filter :routing_tag_ids_empty, apply: lambda { |records, values, _options|
    records.routing_tag_ids_empty(values[0])
  }

  filter :customer_auth_external_type_eq, apply: lambda { |records, values, _options|
    records.where(customer_auth_external_type: values)
  }

  filter :customer_auth_external_type_not_eq, apply: lambda { |records, values, _options|
    records.where(customer_auth_external_type: nil).or(records.where.not(customer_auth_external_type: values))
  }

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
  ransack_filter :is_last_cdr, type: :boolean
  ransack_filter :lega_disconnect_code, type: :number
  ransack_filter :lega_disconnect_reason, type: :string
  ransack_filter :node_id, type: :number
  ransack_filter :src_name_in, type: :string
  ransack_filter :src_name_out, type: :string
  ransack_filter :diversion_in, type: :string
  ransack_filter :diversion_out, type: :string
  ransack_filter :legb_disconnect_code, type: :number
  ransack_filter :legb_disconnect_reason, type: :string
  ransack_filter :dump_level_id, type: :number
  ransack_filter :auth_orig_ip, type: :inet
  ransack_filter :auth_orig_port, type: :number
  ransack_filter :global_tag, type: :string
  ransack_filter :src_country_id, type: :number
  ransack_filter :src_network_id, type: :number
  ransack_filter :dst_country_id, type: :number
  ransack_filter :dst_network_id, type: :number
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
  ransack_filter :destination_rate_policy_id, type: :number

  # add supporting associations from non cdr namespaces
  def self.resource_for(type)
    if type.in?(CONST::ROOT_NAMESPACE_RELATIONS)
      "Api::Rest::Admin::#{type}Resource".safe_constantize
    elsif type.in?(CONST::SYSTEM_NAMESPACE_RELATIONS)
      "Api::Rest::Admin::System::#{type}Resource".safe_constantize
    elsif type.in?(CONST::ROUTING_NAMESPACE_RELATIONS)
      "Api::Rest::Admin::Routing::#{type}Resource".safe_constantize
    else
      super
    end
  end
end
