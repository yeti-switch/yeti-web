# frozen_string_literal: true

class Api::Rest::Admin::PopResource < ::BaseResource
  attributes :name
  filter :name # DEPRECATED

  ransack_filter :name, type: :string
end
