class Api::Rest::Admin::Equipment::Radius::AuthProfileResource < ::BaseResource
  model_name 'Equipment::Radius::AuthProfile'

  attributes :name, :server, :port, :secret, :reject_on_error, :timeout, :attempts

end
