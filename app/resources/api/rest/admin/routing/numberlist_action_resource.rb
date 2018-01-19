class Api::Rest::Admin::Routing::NumberlistActionResource < ::BaseResource
  model_name 'Routing::NumberlistAction'
  immutable

  attributes :name
end
