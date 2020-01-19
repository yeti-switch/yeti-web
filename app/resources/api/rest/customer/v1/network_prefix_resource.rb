# frozen_string_literal: true

class Api::Rest::Customer::V1::NetworkPrefixResource < BaseResource
  model_name 'System::NetworkPrefix'

  key_type :uuid
  primary_key :uuid
  paginator :paged

  attributes :prefix,
             :number_min_length,
             :number_max_length

  has_one :network, class_name: 'Network', foreign_key_on: :related

  ransack_filter :prefix, type: :string
  ransack_filter :number_min_length, type: :string
  ransack_filter :number_max_length, type: :string
end
