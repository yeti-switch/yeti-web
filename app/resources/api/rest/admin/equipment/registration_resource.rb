# frozen_string_literal: true

class Api::Rest::Admin::Equipment::RegistrationResource < ::BaseResource
  model_name 'Equipment::Registration'
  paginator :paged

  attributes :auth_password,
             :auth_user,
             :contact,
             :display_username,
             :domain,
             :enabled,
             :expire,
             :force_expire,
             :max_attempts,
             :name,
             :proxy,
             :retry_delay,
             :sip_interface_name,
             :username,
             :sip_schema_id

  has_one :transport_protocol, class_name: 'TransportProtocol', always_include_linkage_data: true
  has_one :proxy_transport_protocol, class_name: 'TransportProtocol', always_include_linkage_data: true
  has_one :pop, class_name: 'Pop', always_include_linkage_data: true
  has_one :node, class_name: 'Node', always_include_linkage_data: true
end
