# frozen_string_literal: true

class Api::Rest::Admin::IncomingRegistrationResource < ::BaseResource
  model_name 'RealtimeData::IncomingRegistration'
  paginator :none
  key_type :string

  attributes :auth_id, :contact, :expires, :path, :user_agent

  has_one :gateway, class_name: 'Gateway'

  filter :auth_id_eq

  def self.sortable_fields(_context = nil)
    []
  end

  def self.find_records(filters, _options = {})
    result = Yeti::RpcCalls::IncomingRegistrations.call Node.all, auth_id: filters[:auth_id_eq]&.first

    registrations = result.data.map { |row| RealtimeData::IncomingRegistration.new(row) }
    RealtimeData::IncomingRegistration.load_associations(registrations, :gateway)
    registrations
  end

  def self.find_count(_verified_filters, _options)
    0
  end
end
