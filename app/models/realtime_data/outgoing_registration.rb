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
      :node_id
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