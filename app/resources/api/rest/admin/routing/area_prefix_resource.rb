class Api::Rest::Admin::Routing::AreaPrefixResource < ::BaseResource
  model_name 'Routing::AreaPrefix'

  attributes :prefix

  has_one :area, class_name: 'Area'
end
