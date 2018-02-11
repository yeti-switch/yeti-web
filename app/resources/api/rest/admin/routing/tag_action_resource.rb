class Api::Rest::Admin::Routing::TagActionResource < ::BaseResource
  model_name 'Routing::TagAction'
  immutable

  attributes :name
end
