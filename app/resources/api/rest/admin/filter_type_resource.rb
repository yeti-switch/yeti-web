# frozen_string_literal: true

class Api::Rest::Admin::FilterTypeResource < ::BaseResource
  immutable
  attributes :name
  paginator :paged
  filter :name # DEPRECATED

  ransack_filter :name, type: :string
end
