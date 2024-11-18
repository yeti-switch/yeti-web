# frozen_string_literal: true

class Api::Rest::Admin::TagActionResource < ::BaseResource
  model_name 'Routing::TagAction'
  immutable

  attributes :name

  paginator :paged

  ransack_filter :name, type: :string
end
