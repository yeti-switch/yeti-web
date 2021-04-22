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
             :to_uri,
             :created_at,
             :updated_at,
             :external_id

  has_one :node, class_name: 'Node'
  has_one :pop, class_name: 'Pop'
  has_one :proxy_transport_protocol, class_name: 'TransportProtocol'
  has_one :sip_schema, class_name: 'SipSchema'
  has_one :transport_protocol, class_name: 'TransportProtocol'
end
