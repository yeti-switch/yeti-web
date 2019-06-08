# frozen_string_literal: true

class RealtimeData::OutgoingRegistration < YetiResource
  attribute :id
  attribute :user
  attribute :domain
  attribute :state
  attribute :auth_user
  attribute :display_name
  attribute :contact
  attribute :proxy
  attribute :expires
  attribute :expires_left
  attribute :node_id, :integer
  attribute :last_error_code
  attribute :last_error_initiator
  attribute :last_error_reason
  attribute :last_request_time
  attribute :last_succ_reg_time
  attribute :attempt
  attribute :max_attempts
  attribute :retry_delay

  has_one :node, class_name: 'Node', foreign_key: :node_id

  class << self
    def human_attributes(only = nil)
      attrs = only || attribute_types.keys.map(&:to_sym)
      fkeys_to_names = association_types.map { |name, opts| [opts[:foreign_key].to_sym, name.to_sym] }.to_h
      # attrs =  attrs & Array.wrap(only) if only
      attrs.map { |attr| fkeys_to_names.fetch(attr, attr) }
    end
  end

  def display_name
    id
  end
end
