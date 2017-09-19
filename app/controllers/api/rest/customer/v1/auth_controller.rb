class Api::Rest::Customer::V1::AuthController < Knock::AuthTokenController

  private

  def entity_name
    'System::ApiAccess'
  end

  def auth_params
    params.require(:auth).permit(:login, :password)
  end

  def remote_ip
    request.env['HTTP_X_REAL_IP'] || request.remote_ip
  end

  def authenticate
    super
    authenticate_allowed_ip
  end

  def authenticate_allowed_ip
    unless entity.present? && entity.authenticate_ip(remote_ip)
      raise Knock.not_found_exception_class
    end
  end
end
