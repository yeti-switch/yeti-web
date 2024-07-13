# frozen_string_literal: true

class RealtimeData::IncomingRegistration < YetiResource
  include Memoizable

  attribute :node_id, :integer
  attribute :auth_id, :integer
  attribute :contact
  attribute :expires
  attribute :path
  attribute :user_agent

  has_one :gateway, class_name: 'Gateway', foreign_key: :auth_id
  has_one :node, class_name: 'Node', foreign_key: :node_id

  define_memoizable :id, apply: lambda {
    SecureRandom.uuid
  }
end
