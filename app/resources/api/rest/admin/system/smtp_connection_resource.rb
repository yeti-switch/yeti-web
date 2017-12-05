class Api::Rest::Admin::System::SmtpConnectionResource < ::BaseResource
  model_name 'System::SmtpConnection'

  attributes :name, :host , :port, :from_address, :auth_user, :auth_password, :global

  filter :name
end
