# frozen_string_literal: true

class Api::Rest::Customer::V1::NetworkTypeResource < BaseResource
  model_name 'System::NetworkType'

  key_type :uuid
  primary_key :uuid
  paginator :paged

  attributes :name

  ransack_filter :name, type: :string
end
