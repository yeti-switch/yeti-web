class RealtimeData::OutgoingRegistration  < YetiResource

  attr_accessor :node

  DYNAMIC_ATTRIBUTES = [
      :id,
      :user,
      :domain,
      :state,
      :auth_user,
      :display_name,
      :contact,
      :proxy,
      :expires,
      :expires_left,
      :node_id,
      :last_error_code,
      :last_error_initiator,
      :last_error_reason,
      :last_request_time,
      :last_succ_reg_time,
      :attempt,
      :max_attempts,
      :retry_delay
  ]

  attr_accessor *DYNAMIC_ATTRIBUTES
  #include Yeti::OutgoingRegistrations

  FOREIGN_KEYS_ATTRIBUTES = {
      node_id: Node
  }


  def display_name
    self.id
  end

  def to_param
    self.id
  end



end