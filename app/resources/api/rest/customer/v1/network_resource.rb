# frozen_string_literal: true

class Api::Rest::Customer::V1::NetworkResource < Api::Rest::Customer::V1::BaseResource
  model_name 'System::Network'

  attributes :name

  has_one :network_type, class_name: 'NetworkType', foreign_key_on: :related

  ransack_filter :name, type: :string
end
