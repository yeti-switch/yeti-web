# frozen_string_literal: true

class Api::Rest::Admin::AuthProfileResource < ::BaseResource
  model_name 'Equipment::Radius::AuthProfile'

  attributes :name, :server, :port, :secret, :reject_on_error, :timeout, :attempts

  paginator :paged

  filter :name
end
