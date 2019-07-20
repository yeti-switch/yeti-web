# frozen_string_literal: true

class RealtimeData::IncomingRegistration < YetiResource
  include Memoizable

  attribute :auth_id, :integer
  attribute :contact
  attribute :expires
  attribute :path
  attribute :user_agent

  has_one :gateway, class_name: 'Gateway', foreign_key: :auth_id

  define_memoizable :id do
    SecureRandom.uuid
  end
end
