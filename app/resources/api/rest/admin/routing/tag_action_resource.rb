# frozen_string_literal: true

class Api::Rest::Admin::Routing::TagActionResource < ::BaseResource
  model_name 'Routing::TagAction'
  immutable

  attributes :name

  ransack_filter :name, type: :string
end
