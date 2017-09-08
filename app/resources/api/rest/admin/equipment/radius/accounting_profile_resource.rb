class Api::Rest::Admin::Equipment::Radius::AccountingProfileResource < ::BaseResource
  model_name 'Equipment::Radius::AccountingProfile'

  attributes :name, :server, :port, :secret, :timeout, :attempts, :enable_start_accounting,
             :enable_interim_accounting, :interim_accounting_interval, :enable_stop_accounting
end
