# frozen_string_literal: true

class Api::Rest::Admin::NodeResource < ::BaseResource
  attributes :name, :rpc_endpoint

  paginator :paged

  has_one :pop, always_include_linkage_data: true

  ransack_filter :pop_id, type: :foreign_key

  ransack_filter :id, type: :number
  ransack_filter :name, type: :string
  ransack_filter :rpc_endpoint, type: :string

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
