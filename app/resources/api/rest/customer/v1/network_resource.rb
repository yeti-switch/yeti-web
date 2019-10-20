# frozen_string_literal: true

class Api::Rest::Customer::V1::NetworkResource < BaseResource
  model_name 'System::Network'

  key_type :uuid
  primary_key :uuid
  paginator :paged

  attributes :name

  has_one :network_type, class_name: 'NetworkType', foreign_key_on: :related

  ransack_filter :name, type: :string
end
