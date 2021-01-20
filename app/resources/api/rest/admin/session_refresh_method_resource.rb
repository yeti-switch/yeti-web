# frozen_string_literal: true

class Api::Rest::Admin::SessionRefreshMethodResource < ::BaseResource
  immutable
  attributes :name, :value
  paginator :paged
  filter :name # DEPRECATED

  ransack_filter :name, type: :string
end
