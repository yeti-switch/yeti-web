# frozen_string_literal: true

class Api::Rest::Admin::Routing::AreaResource < ::BaseResource
  model_name 'Routing::Area'

  attributes :name

  ransack_filter :name, type: :string
end
