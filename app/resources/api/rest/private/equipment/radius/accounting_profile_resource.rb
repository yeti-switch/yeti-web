class Api::Rest::Private::Equipment::Radius::AccountingProfileResource < ::BaseResource
  immutable
  model_name 'Equipment::Radius::AccountingProfile'
  type 'equipment/radius/accounting_profiles'

  attributes :name, :server, :port, :secret, :timeout, :attempts, :enable_start_accounting,
             :enable_interim_accounting, :interim_accounting_interval, :enable_stop_accounting
end
