class Api::Rest::Admin::Routing::RoutesetDiscriminatorResource < ::BaseResource
  model_name 'Routing::RoutesetDiscriminator'

  attributes :name
  filter :name

  def self.updatable_fields(context)
    [:name]
  end

  def self.creatable_fields(context)
    self.updatable_fields(context)
  end

end
