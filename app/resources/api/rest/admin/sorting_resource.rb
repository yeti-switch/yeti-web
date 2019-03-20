# frozen_string_literal: true

class Api::Rest::Admin::SortingResource < ::BaseResource
  attributes :name, :description, :use_static_routes
  filter :name # DEPRECATED

  ransack_filter :name, type: :string
end
