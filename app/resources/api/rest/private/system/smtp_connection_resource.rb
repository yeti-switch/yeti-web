class Api::Rest::Private::System::SmtpConnectionResource < ::BaseResource
  model_name 'System::SmtpConnection'
  # type 'system/smtp_connections'

  attributes :name, :host , :port, :from_address, :auth_user, :auth_password, :global
end