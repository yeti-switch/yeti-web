# frozen_string_literal: true

class Api::Rest::Admin::NodeResource < ::BaseResource
  attributes :name, :rpc_endpoint

  has_one :pop

  filter :name # DEPRECATED

  ransack_filter :name, type: :string

  def self.updatable_fields(_context)
    %i[
      id
      name
      rpc_endpoint
      pop
    ]
  end

  def self.creatable_fields(context)
    updatable_fields(context)
  end
end
