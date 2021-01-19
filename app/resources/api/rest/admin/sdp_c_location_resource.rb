# frozen_string_literal: true

class Api::Rest::Admin::SdpCLocationResource < ::BaseResource
  immutable
  attributes :name
  paginator :paged
  filter :name # DEPRECATED

  ransack_filter :name, type: :string
end
