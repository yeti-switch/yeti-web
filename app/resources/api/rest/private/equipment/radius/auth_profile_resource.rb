class Api::Rest::Private::Equipment::Radius::AuthProfileResource < ::BaseResource
  immutable
  model_name 'Equipment::Radius::AuthProfile'
  type 'equipment/radius/auth_profiles'

  attributes :name, :server, :port, :secret, :reject_on_error, :timeout, :attempts

end
