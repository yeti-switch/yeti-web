class Api::Rest::Private::SortingResource < JSONAPI::Resource
  immutable

  attributes :name, :description, :use_static_routes
end
