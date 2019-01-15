# frozen_string_literal: true

class Api::Rest::Admin::Routing::NumberlistActionResource < ::BaseResource
  model_name 'Routing::NumberlistAction'
  immutable

  attributes :name
end
