# frozen_string_literal: true

class Api::Rest::Admin::DisconnectPolicyResource < ::BaseResource
  attributes :name

  paginator :paged

  filter :name # DEPRECATED

  ransack_filter :name, type: :string
end
