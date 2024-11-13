# frozen_string_literal: true

class Api::Rest::Admin::NodeResource < ::BaseResource
  attributes :name, :rpc_endpoint

  paginator :paged

  has_one :pop, always_include_linkage_data: true

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
