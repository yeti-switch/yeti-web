class Api::Rest::Private::RoutingPlanResource < JSONAPI::Resource
  model_name 'Routing::RoutingPlan'
  attributes :name, :rate_delta_max, :use_lnp

  has_one :sorting

  def self.updatable_fields(context)
    [
      :name,
      :rate_delta_max,
      :use_lnp,
      :sorting
    ]
  end

  def self.creatable_fields(context)
    self.updatable_fields(context)
  end
end
