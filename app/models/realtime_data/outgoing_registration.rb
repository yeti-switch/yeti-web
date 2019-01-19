# frozen_string_literal: true

class RealtimeData::OutgoingRegistration < YetiResource
  attr_accessor :node

  DYNAMIC_ATTRIBUTES = %i[
    id
    user
    domain
    state
    auth_user
    display_name
    contact
    proxy
    expires
    expires_left
    node_id
    last_error_code
    last_error_initiator
    last_error_reason
    last_request_time
    last_succ_reg_time
    attempt
    max_attempts
    retry_delay
  ].freeze

  attr_accessor *DYNAMIC_ATTRIBUTES
  # include Yeti::OutgoingRegistrations

  FOREIGN_KEYS_ATTRIBUTES = {
    node_id: Node
  }.freeze

  def display_name
    id
  end

  def to_param
    id
  end
end
