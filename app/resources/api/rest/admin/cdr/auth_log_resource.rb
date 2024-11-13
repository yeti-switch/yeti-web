# frozen_string_literal: true

class Api::Rest::Admin::Cdr::AuthLogResource < BaseResource
  immutable
  model_name 'Cdr::AuthLog'
  paginator :paged

  module CONST
    ROOT_NAMESPACE_RELATIONS = %w[
      Gateway Pop Node
    ].freeze
    EQUIPMENT_NAMESPACE_RELATIONS = %w[TransportProtocol].freeze

    freeze
  end

  def self.default_sort
    [{ field: 'request_time', direction: :desc }]
  end

  attributes :request_time,
             :success,
             :code,
             :reason,
             :internal_reason,
             :origination_ip, :origination_port, :origination_proto_id, :transport_proto_id,
             :transport_remote_ip, :transport_remote_port,
             :transport_local_ip, :transport_local_port,
             :pop_id,
             :node_id,
             :gateway_id,
             :username, :realm,
             :request_method,
             :ruri,
             :from_uri, :to_uri,
             :call_id,
             :nonce, :response,
             :x_yeti_auth,
             :diversion, :pai, :ppi, :privacy, :rpid, :rpid_privacy

  has_one :gateway, class_name: 'Gateway', force_routed: true, always_include_linkage_data: true
  has_one :pop, class_name: 'Pop', force_routed: true, always_include_linkage_data: true
  has_one :node, class_name: 'Node', force_routed: true, always_include_linkage_data: true
  has_one :origination_protocol, class_name: 'TransportProtocol', foreign_key: :origination_proto_id, force_routed: true, always_include_linkage_data: true
  has_one :transport_protocol, class_name: 'TransportProtocol', foreign_key: :transport_proto_id, force_routed: true, always_include_linkage_data: true

  filter :request_time_gteq, apply: lambda { |records, values, _options|
    records.where('request_time >= ?', values[0])
  }
  filter :request_time_lteq, apply: lambda { |records, values, _options|
    records.where('request_time <= ?', values[0])
  }

  ransack_filter :request_time, type: :datetime
  ransack_filter :success, type: :boolean
  ransack_filter :code, type: :number
  ransack_filter :reason, type: :string
  ransack_filter :internal_reason, type: :string
  ransack_filter :origination_ip, type: :string
  ransack_filter :origination_port, type: :number
  ransack_filter :origination_proto_id, type: :number
  ransack_filter :transport_proto_id, type: :number
  ransack_filter :transport_remote_ip, type: :string
  ransack_filter :transport_remote_port, type: :number
  ransack_filter :transport_local_ip, type: :string
  ransack_filter :transport_local_port, type: :number
  ransack_filter :pop_id, type: :number
  ransack_filter :node_id, type: :number
  ransack_filter :gateway_id, type: :number
  ransack_filter :username, type: :string
  ransack_filter :realm, type: :string
  ransack_filter :request_method, type: :string
  ransack_filter :ruri, type: :string
  ransack_filter :from_uri, type: :string
  ransack_filter :to_uri, type: :string
  ransack_filter :call_id, type: :string
  ransack_filter :nonce, type: :string
  ransack_filter :response, type: :string
  ransack_filter :x_yeti_auth, type: :string
  ransack_filter :diversion, type: :string
  ransack_filter :pai, type: :string
  ransack_filter :ppi, type: :string
  ransack_filter :privacy, type: :string
  ransack_filter :rpid, type: :string
  ransack_filter :rpid_privacy, type: :string

  def self.resource_for(type)
    if type.in?(CONST::ROOT_NAMESPACE_RELATIONS)
      "Api::Rest::Admin::#{type}Resource".safe_constantize
    elsif type.in?(CONST::EQUIPMENT_NAMESPACE_RELATIONS)
      "Api::Rest::Admin::Equipment::#{type}Resource".safe_constantize
    else
      super
    end
  end
end
