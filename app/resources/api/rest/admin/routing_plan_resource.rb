class Api::Rest::Admin::RoutingPlanResource < JSONAPI::Resource
  model_name 'Routing::RoutingPlan'

  attributes :name, :rate_delta_max, :use_lnp

  has_one :sorting

  filter :name

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
