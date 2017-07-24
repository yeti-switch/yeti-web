class Api::Rest::Private::AuthController < Knock::AuthTokenController

  private

  def entity_name
    'AdminUser'
  end

  def auth_params
    params.require(:auth).permit :username, :password
  end
end
