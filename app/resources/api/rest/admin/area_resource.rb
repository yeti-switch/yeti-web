# frozen_string_literal: true

class Api::Rest::Admin::AreaResource < ::BaseResource
  model_name 'Routing::Area'

  attributes :name

  paginator :paged

  ransack_filter :name, type: :string
end
