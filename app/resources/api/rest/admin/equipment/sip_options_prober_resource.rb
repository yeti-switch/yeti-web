# frozen_string_literal: true

class Api::Rest::Admin::Equipment::SipOptionsProberResource < ::BaseResource
  model_name 'Equipment::SipOptionsProber'
  paginator :paged

  attributes :append_headers,
             :auth_password,
             :auth_username,
             :contact_uri,
             :enabled,
             :from_uri,
             :interval,
             :name,
             :proxy,
             :ruri_domain,
             :ruri_username,
             :sip_interface_name,
             :sip_schema_id,
             :to_uri,
             :created_at,
             :updated_at,
             :external_id

  has_one :node, class_name: 'Node', always_include_linkage_data: true
  has_one :pop, class_name: 'Pop', always_include_linkage_data: true
  has_one :proxy_transport_protocol, class_name: 'TransportProtocol', always_include_linkage_data: true
  has_one :transport_protocol, class_name: 'TransportProtocol', always_include_linkage_data: true
end
