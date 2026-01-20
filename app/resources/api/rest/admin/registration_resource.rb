# frozen_string_literal: true

class Api::Rest::Admin::RegistrationResource < ::BaseResource
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
             :route_set,
             :retry_delay,
             :sip_interface_name,
             :username,
             :sip_schema_id

  has_one :transport_protocol, class_name: 'TransportProtocol'
  has_one :pop, class_name: 'Pop'
  has_one :node, class_name: 'Node'
end
